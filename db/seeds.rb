require 'byebug'
require 'rest-client'
require 'json'

url = "https://openstates.org/graphql"

ny_senate = "ocd-organization/8291a233-623d-40e8-882d-21ec2d382c87"
ny_assembly = "ocd-organization/26bb6306-85f0-4d10-bff7-d1cd5bdc0865"
tx_senate = ""
tx_assembly = ""

legislator_query = '{
  people(first: 100, memberOf: "ocd-organization/8291a233-623d-40e8-882d-21ec2d382c87") {
    edges {
      node {
        name
        image
        party: currentMemberships(classification:"party") {
          organization {
            name

          }
        }
        chamber: currentMemberships(classification:["upper", "lower"]) {
          post {
            label
            role
          }
          organization {
            name
          }
        }
        committees: currentMemberships(classification:"committee") {
          organization {
            name
          }
        }
        contactDetails {
        	type
          value
          note
        }
      }
    }
  }
}'

payload = {
  query: legislator_query
}

headers = {
  "X-API-KEY": ENV["OS_KEY"]
}

response = RestClient.post(url, payload, headers )
json = JSON.parse(response)
puts json
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

