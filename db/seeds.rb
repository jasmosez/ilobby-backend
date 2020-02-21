require 'byebug'
require 'rest-client'
require 'json'

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
# legislator object
# committee objects (if any don't already exist)
# committee_legislator objects
# contact_info objects
# legislator_contact_info objects
jsons.each do |json|
  json["data"]["people"]["edges"].each do |edge|
    legislator = edge["node"]

    id = legislator["id"]
    name = legislator["name"]
    image = legislator["image"]
    # puts 'legislator["image"] => ' + image
    
    
    
    # puts 'legislator["parties"] => '
    # legislator["party"].each do |org|
    #   puts '["organization"]["name"] => ' + org["organization"]["name"]      
    # end
    
    # puts 'legislator["chamber(s)"] => '
    # legislator["chamber"].each do |chamber|
    #   puts 'chamber => '
    #   puts 'chamber["post"]["label"] => ' + chamber["post"]["label"]
    #   puts 'chamber["post"]["role"] => ' + chamber["post"]["role"]
    #   puts 'chamber["organization"]["name"] => ' + chamber["organization"]["name"]
    # end
    
    legislatorObj = Legislator.create(open_states_id: id, 
                      name: name, 
                      image: image, 
                      party: legislator["party"].first["organization"]["name"],
                      district: legislator["chamber"].first["post"]["label"],
                      role: legislator["chamber"].first["post"]["role"],
                      chamber: legislator["chamber"].first["organization"]["name"]
                    )

    # puts 'legislator["committees"] => ' 
    legislator["committees"].each do |committee|
      # puts 'committee["organization"] => '
      # puts 'committee["organization"]["id"] => ' + committee["organization"]["id"].to_s
      # puts 'committee["organization"]["name"] => ' + committee["organization"]["name"].to_s
      committeeObj = Committee.all.find_by(open_states_id: committee["organization"]["id"])
      puts committeeObj
      if !committeeObj
        committeeObj = Committee.create(open_states_id: committee["organization"]["id"], name: committee["organization"]["name"], chamber: committee["organization"]["parent"]["name"])
        puts committeeObj
      end
      CommitteeLegislator.create(legislator_id: legislatorObj.id, committee_id: committeeObj.id)
    end

    # puts 'legislator["contactDetails"] => ' 
    legislator["contactDetails"].each do |detail|
      # puts 'contactDetail => '
      # puts 'contactDetail["type"] => ' + detail["type"]
      # puts 'contactDetail["value"] => ' + detail["value"]
      # puts 'contactDetail["note"] => ' + detail["note"]
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

