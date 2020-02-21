require 'byebug'
require 'rest-client'
require 'json'

LegislatorContactInfo.all.delete_all
ContactInfo.all.delete_all
CommitteeLegislator.all.delete_all
Legislator.all.delete_all
Committee.all.delete_all

url = "https://openstates.org/graphql"

# build array of goverment organization ids from Open States
gov_bodies = [
  {slug: "ny_upper", id: "ocd-organization/8291a233-623d-40e8-882d-21ec2d382c87"},
  {slug: "ny_lower", id: "ocd-organization/26bb6306-85f0-4d10-bff7-d1cd5bdc0865"}
  # {slug: "tx_upper", id: ""},
  # {slug: "tx_lower", id: ""}
]

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

# header requires the API key
headers = {
  "X-API-KEY": ENV["OS_KEY"]
}

# array to collect response of each POST request
jsons = []

# iterate through government bodies, make POST requests and handle pagination
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

# parse each json response into:
jsons.each do |json|
  json["data"]["people"]["edges"].each do |edge|
    legislator = edge["node"]
    
    id = legislator["id"]
    name = legislator["name"]
    image = legislator["image"]
    
    # legislator object
    legislator_obj = Legislator.create(open_states_id: id, 
      name: name, 
      image: image, 
      party: legislator["party"].first["organization"]["name"],
      district: legislator["chamber"].first["post"]["label"],
      role: legislator["chamber"].first["post"]["role"],
      chamber: legislator["chamber"].first["organization"]["name"]
    )
    
    legislator["committees"].each do |committee|
      
      # create committee objects (if any don't already exist)
      committee_obj = Committee.all.find_by(open_states_id: committee["organization"]["id"])
      puts committee_obj
      if !committee_obj
        committee_obj = Committee.create(open_states_id: committee["organization"]["id"], name: committee["organization"]["name"], chamber: committee["organization"]["parent"]["name"])
        puts committee_obj
      end
      
      # committee_legislator objects
      CommitteeLegislator.create(legislator_id: legislator_obj.id, committee_id: committee_obj.id)
    end
    
    # puts 'legislator["contactDetails"] => ' 
    legislator["contactDetails"].each do |detail|
      # contact_info objects
      contact_info_object = ContactInfo.create(kind: detail["type"], value: detail["value"], note: detail["note"])
      # puts 'contactDetail["type"] => ' + detail["type"]
      # puts 'contactDetail["value"] => ' + detail["value"]
      # puts 'contactDetail["note"] => ' + detail["note"]
      
      # legislator_contact_info objects
      LegislatorContactInfo.create(legislator_id: legislator_obj.id, contact_info_id: contact_info_object.id)
    end

    # puts "------------------------"
  end
end

byebug
0

# create legislator
# for each committee
#   create committee, if committee with that id does not already exist => jsons.last["data"]["people"]["edges"].last["node"]["committees"].first["organization"]["id"]
#   create committee_legislator
# end
# for each contact_info
#   create contact_info
#   create legislator_contact_infos
# end

# jsons.last["data"]["people"]["edges"].last["node"].keys
# ["id", "name", "image", "party", "chamber", "committees", "contactDetails"]


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

