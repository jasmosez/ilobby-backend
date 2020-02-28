require 'byebug'
require 'rest-client'
require 'json'

def delete_gov_bodies_data
  ContactInfo.all.delete_all
  CommitteeLegislator.all.delete_all
  Legislator.all.delete_all
  Committee.all.delete_all
end

# method to return a string for the body of a POST request to the Open States API
# takes the open_states_id of a government body and 'after', a string returned by server for pagination
def legislator_query(gov_body_id, after)
  return "{
    people(first: 100, memberOf: \"#{gov_body_id}\", after: \"#{after}\") {
      edges {
        node {
          id
          name
          image
          party: currentMemberships(classification:\"party\") {
            organization {
              name

            }
          }
          chamber: currentMemberships(classification:[\"upper\", \"lower\"]) {
            post {
              label
              role
              division {
                id
                name
              }
            }
            organization {
              name
            }
          }
          committees: currentMemberships(classification:\"committee\") {
            organization {
              name
              id
              parent {
                name
              }
            }
          }
          contactDetails {
            type
            value
            note
          }
        }
      }
      pageInfo {
        hasNextPage
        endCursor
      }
      totalCount
    }
  }"
end

# iterate through an array of government bodies, make POST requests and handle pagination
def fetch_gov_bodies_data
  
  # array of goverment organization ids from Open States
  gov_bodies = [
    {slug: "ny_upper", id: "ocd-organization/8291a233-623d-40e8-882d-21ec2d382c87"},
    {slug: "ny_lower", id: "ocd-organization/26bb6306-85f0-4d10-bff7-d1cd5bdc0865"}
    # {slug: "tx_upper", id: ""},
    # {slug: "tx_lower", id: ""}
  ]
  
  url = "https://openstates.org/graphql"

  # header requires the API key
  headers = {"X-API-KEY": ENV["OS_KEY"]}

  # array to collect response of each POST request
  jsons = []


  gov_bodies.each do |gov_body|

    hasNextPage = true
    after=""

    while hasNextPage
      payload = {
        query: legislator_query(gov_body[:id], after)
      }

      response = RestClient.post(url, payload, headers )
      json = JSON.parse(response)
      jsons << json
      
      hasNextPage = json["data"]["people"]["pageInfo"]["hasNextPage"]
   
      if hasNextPage
        after = json["data"]["people"]["pageInfo"]["endCursor"]
      end

    end

  end
  return jsons
end

def create_legislator(edge)
  legislator = edge["node"]
    
  id = legislator["id"]
  name = legislator["name"]
  image = legislator["image"]
  
  # create legislator object
  legislator_obj = Legislator.create(
    open_states_id: id, 
    name: name, 
    image: image, 
    party: legislator["party"].first["organization"]["name"],
    district: legislator["chamber"].first["post"]["label"],
    role: legislator["chamber"].first["post"]["role"],
    geo: fetch_geo_data(legislator["chamber"].first["post"]["division"]["id"]).to_json,
    chamber: legislator["chamber"].first["organization"]["name"]
  )

  return legislator_obj.id
end

def create_committees_and_assignments(edge, id)
  # iterate through the legislator's committees
    edge["node"]["committees"].each do |committee|
      
      # create committee object (if it doesn't already exist)
      committee_obj = Committee.all.find_by(open_states_id: committee["organization"]["id"])

      if !committee_obj
        committee_obj = Committee.create(open_states_id: committee["organization"]["id"], name: committee["organization"]["name"], chamber: committee["organization"]["parent"]["name"])
      end
      
      # create committee_legislator object
      CommitteeLegislator.create(legislator_id: id, committee_id: committee_obj.id)
    end
end

def create_contact_information(edge, id)
  # iterate through the legislator's contact details
  edge["node"]["contactDetails"].each do |detail|
    # create contact_info object
    contact_info_object = ContactInfo.create(kind: detail["type"], value: detail["value"], note: detail["note"], legislator_id: id)
  end


end

def fetch_geo_data(district_id)
  puts district_id
  url = "https://data.openstates.org/boundaries/2018/#{district_id}.json"
  response = RestClient.get(url)
  json = JSON.parse(response)
end

def parse_gov_bodies_data(jsons)
  # iterate through each json response item 
  jsons.each do |json|
    # iterate through each 'edge (i.e. person) and parse:
    json["data"]["people"]["edges"].each do |edge|
      id = create_legislator(edge)
      create_committees_and_assignments(edge, id)
      create_contact_information(edge, id)
    end
  end
end


def create_dummy_data
  dummy_user_id = 1
  Campaign.create(user_id: dummy_user_id, name: "Bail Reform")
  Campaign.create(user_id: dummy_user_id, name: "Greenlight NYC")
  Campaign.create(user_id: dummy_user_id, name: "Single Payer Healthcare")
end

delete_gov_bodies_data
parse_gov_bodies_data(fetch_gov_bodies_data)
create_dummy_data



byebug
0


# GraphiQL query object to get all legislatures and their children
# {
#   jurisdictions {
#     edges {
#       node {
#         id
#         name
#         organizations(first: 50, classification: "legislature") {
#           edges {
#             node {
#               id
#               name
#               classification
#               children(first: 5) {
#                 edges {
#                   node {
#                     id
#                     name
#                     classification
#                   }
#                 }
#               }
#             }
#           }
#         }
#       }
#     }
#   }
# }

