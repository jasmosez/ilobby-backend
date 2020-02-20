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
    puts json
    jsons << json
    
    hasNextPage = json["data"]["people"]["pageInfo"]["hasNextPage"]
    if hasNextPage
      after = json["data"]["people"]["pageInfo"]["endCursor"]
    end
    byebug
    0

  end

end



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

