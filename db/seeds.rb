require 'byebug'
require 'rest-client'
require 'json'

url = "https://openstates.org/graphql"


gov_bodies = [
  {slug: "ny_upper", id: "ocd-organization/8291a233-623d-40e8-882d-21ec2d382c87"},
  {slug: "ny_lower", id: "ocd-organization/26bb6306-85f0-4d10-bff7-d1cd5bdc0865"}
  # {slug: "tx_upper", id: ""},
  # {slug: "tx_lower", id: ""}
]

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

headers = {
  "X-API-KEY": ENV["OS_KEY"]
}

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

puts 'jsons.last["data"]["people"]["edges"]'
byebug
puts jsons.last["data"]["people"]["edges"]

puts 'jsons.last["data"]["people"]["edges"].last["node"]'
byebug
puts jsons.last["data"]["people"]["edges"].last["node"]

jsons.each do |json|
  json["data"]["people"]["edges"].each do |edge|
    puts "------------------------"
    puts edge["node"]
    legislator = edge["node"]
    puts 'legislator["id"] => ' + legislator["id"]
    puts 'legislator["name"] => ' + legislator["name"]
    puts 'legislator["image"] => ' + legislator["image"]
    puts 'legislator["party"] => ' + legislator["party"].to_s
    puts 'legislator["chamber"] => ' + legislator["chamber"].to_s
    puts 'legislator["committees"] => ' 
    legislator["committees"].each do |committee|
      puts 'committee => ' + committee.to_s
    end
    legislator["contactDetails"].each do |detail|
      puts 'contactDetail => ' + detail.to_s
    end
    puts "------------------------"

  end
end

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

