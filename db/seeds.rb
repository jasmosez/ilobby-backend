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
    # {slug: "ny_upper", id: "ocd-organization/8291a233-623d-40e8-882d-21ec2d382c87"},
    # {slug: "ny_lower", id: "ocd-organization/26bb6306-85f0-4d10-bff7-d1cd5bdc0865"}
    {slug: "tx_upper", id: "ocd-organization/cabf1716-c572-406a-bfdd-1917c11ac629"},
    {slug: "tx_lower", id: "ocd-organization/d6189dbb-417e-429e-ae4b-2ee6747eddc0"}
    # {slug: "wi_upper", id: "ocd-organization/c8a757e6-378e-468c-a526-e81ca083124b"},
    # {slug: "wi_lower", id: "ocd-organization/2d0dada5-8153-44aa-b436-c92a90db0a9e"}
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
# create_dummy_data



# byebug
# 0


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


def add_twitter_data
  senate_twitter_updates.each do |dist|
    legislator = Legislator.find_by(district: dist[:district], chamber: "Senate")
    legislator.update(twitter: dist[:twitter])
  end

  ny_assembly_twitters.each do |dist|
    legislator = Legislator.find_by(district: dist[:district], chamber: "Assembly")
    legislator.update(twitter: dist[:twitter])
  end

  ny_senate_twitters = [
    # via https://lrany.org/nys-legislator-twitter-handles/
    # accessed: 3/2/20
    {district: 1, web_name: "Kenneth P. LaValle", twitter: "senatorlavalle"},
    {district: 2, web_name: "John J. Flanagan", twitter: "LeaderFlanagan"},
    {district: 3, web_name: "Thomas D. Croci", twitter: "tomcroci"},
    {district: 4, web_name: "Philip M. Boyle", twitter: "PhilBoyleNY"},
    {district: 5, web_name: "Carl L. Marcellino", twitter: "Senator98"},
    {district: 6, web_name: "Kemp Hannon", twitter: "HannonSenate"},
    {district: 7, web_name: "Elaine Phillips"},
    {district: 8, web_name: "John Brooks", twitter: "Brooks4LINY"},
    {district: 9, web_name: "Todd Kaminsky", twitter: "toddkaminsky"},
    {district: 10, web_name: "James Sanders, Jr.", twitter: "JSandersNYC"},
    {district: 11, web_name: "Tony Avella", twitter: "TonyAvella"},
    {district: 12, web_name: "Michael N. Gianaris", twitter: "SenGianaris"},
    {district: 13, web_name: "Jose Peralta", twitter: "SenatorPeralta"},
    {district: 14, web_name: "Leroy Comrie", twitter: "LeroyComrie"},
    {district: 15, web_name: "Joseph Addabbo, Jr."},
    {district: 16, web_name: "Toby Ann Stavisky", twitter: "tobystavisky"},
    {district: 17, web_name: "Simcha Felder", twitter: "NYSenatorFelder"},
    {district: 18, web_name: "Martin Malave Dilan", twitter: "SenatorDilan"},
    {district: 19, web_name: "Roxanne J. Persaud", twitter: "SenatorPersaud"},
    {district: 20, web_name: "Jesse Hamilton", twitter: "SenatorHamilton"},
    {district: 21, web_name: "Kevin S. Parker", twitter: "SenatorParker"},
    {district: 22, web_name: "Martin J. Golden", twitter: "SenMartyGolden"},
    {district: 23, web_name: "Diane Savino", twitter: "dianesavino"},
    {district: 24, web_name: "Andrew J. Lanza", twitter: "senatorlanza"},
    {district: 25, web_name: "Velmanette Montgomery"},
    {district: 26, web_name: "Daniel Squadron", twitter: "DanielSquadron"},
    {district: 27, web_name: "Brad Hoylman", twitter: "bradhoylman"},
    {district: 28, web_name: "Liz Krueger", twitter: "LizKrueger"},
    {district: 29, web_name: "Jose M. Serrano", twitter: "SenatorSerrano"},
    {district: 30, web_name: "Bill Perkins"},
    {district: 31, web_name: "Marisol Alcantara", twitter: "NY31Alcantara"},
    {district: 32, web_name: "Rubén Díaz, Sr.", twitter: "revrubendiaz"},
    {district: 33, web_name: "Gustavo Rivera", twitter: "NYSenatorRivera"},
    {district: 34, web_name: "Jeffrey D. Klein", twitter: "JeffKleinNY"},
    {district: 35, web_name: "Andrea Stewart-Cousins", twitter: "AndreaSCousins"},
    {district: 36, web_name: "Jamaal T. Bailey", twitter: "jamaaltbailey"},
    {district: 37, web_name: "George S. Latimer", twitter: "GeorgeLatimer37"},
    {district: 38, web_name: "David Carlucci", twitter: "davidcarlucci"},
    {district: 39, web_name: "William J. Larkin, Jr.", twitter: "SenatorLarkin"},
    {district: 40, web_name: "Terrence P. Murphy", twitter: "vote4murphy"},
    {district: 41, web_name: "Susan J. Serino", twitter: "Sueserino4ny"},
    {district: 42, web_name: "John J. Bonacic", twitter: "JohnBonacic"},
    {district: 43, web_name: "Kathleen A. Marchione", twitter: "kathymarchione"},
    {district: 44, web_name: "Neil Breslin", twitter: "SenatorBreslin"},
    {district: 45, web_name: "Betty Little", twitter: "bettylittle"},
    {district: 46, web_name: "George A. Amedore, Jr.", twitter: "GeorgeAmedore"},
    {district: 47, web_name: "Joseph Griffo", twitter: "SenGriffo"},
    {district: 48, web_name: "Patty Ritchie", twitter: "SenatorRitchie"},
    {district: 49, web_name: "Jim Tedisco", twitter: "JamesTedisco"},
    {district: 50, web_name: "John DeFrancisco", twitter: "JohnDeFrancisco"},
    {district: 51, web_name: "James Seward"},
    {district: 52, web_name: "Fred Akshar", twitter: "fredakshar"},
    {district: 53, web_name: "David Valesky", twitter: "SenDaveValesky"},
    {district: 54, web_name: "Pam Helming", twitter: "Helming4Senate"},
    {district: 55, web_name: "Richard Funke", twitter: "SenatorFunke"},
    {district: 56, web_name: "Joseph Robach", twitter: "SenatorRobach"},
    {district: 57, web_name: "Catharine Young", twitter: "SenatorYoung"},
    {district: 58, web_name: "Tom O’Mara", twitter: "SenatorOMara"},
    {district: 59, web_name: "Patrick Gallivan", twitter: "senatorgallivan"},
    {district: 60, web_name: "Chris Jacobs", twitter: "JacobsforSenate"},
    {district: 61, web_name: "Michael H. Ranzenhofer"},
    {district: 62, web_name: "Robert G. Ortt", twitter: "SenatorOrtt"},
    {district: 63, web_name: "Timothy M. Kennedy", twitter: "SenKennedy"}
  ]

  senate_twitter_updates = [

    {district: 3, twitter: "NYSSenatorMRM"},
    {district: 5, twitter: "Gaughran4Senate"},
    {district: 6, twitter: "KevinThomasNY"},
    {district: 7, twitter: "AnnaMKaplan"},
    {district: 11, twitter:	"LiuNewYork"},
    {district: 13, twitter:	"jessicaramos"},
    {district: 18, twitter:	"SalazarSenate"},
    {district: 20, twitter:	"SenatorMyrie"},
    {district: 22, twitter:	"Sen_Gounardes"},
    {district: 26, twitter:	"BrianKavanaghNY"},
    {district: 30, twitter:	"NYSenBenjamin"},
    {district: 31, twitter:	"SenatorRJackson"},
    {district: 32, twitter:	"SenSepulveda"},
    {district: 34, twitter:	"SenatorBiaggi"},
    {district: 37, twitter:	"ShelleyBMayer"},
    {district: 39, twitter:	"JamesSkoufis"},
    {district: 40, twitter:	"SenatorHarckham"},
    {district: 42, twitter:	"JenMetzgerNY"},
    {district: 43, twitter:	"NYSenatorJordan"},
    {district: 50, twitter:	nil},
    {district: 53, twitter:	"RachelMayNY"}
  ]

  ny_assembly_twitters = [
    # via https://lrany.org/nys-legislator-twitter-handles/
    # accessed: 3/2/20
    {district: 1, twitter: 'FredThiele1'},
    {district: 2, twitter: 'Palumbo4NYSA'},
    {district: 3, twitter: 'DeanMurrayNYAD3'},
    {district: 4, twitter: 'SteveEngles'},
    {district: 5, twitter: 'AlGrafNY'},
    {district: 6, twitter: 'PhilRamos6AD'},
    {district: 7, twitter: nil},
    {district: 8, twitter: nil},
    {district: 9, twitter: 'josephsaladino9'},
    {district: 10, twitter: 'ChadLupinacci'},
    {district: 11, twitter: 'Kimjeanpierre'},
    {district: 12, twitter: 'AssemblymanRaia'},
    {district: 13, twitter: 'Charles_Lavine'},
    {district: 14, twitter: 'AssemblymanDGM'},
    {district: 15, twitter: 'AsmMontesano'},
    {district: 16, twitter: nil},
    {district: 17, twitter: 'TomMcKevitt1'},
    {district: 18, twitter: nil},
    {district: 19, twitter: 'EdwardRa19'},
    {district: 20, twitter: nil},
    {district: 21, twitter: 'BrianCurranNY'},
    {district: 22, twitter: 'MichaelleSolage'},
    {district: 23, twitter: 'Stacey23AD'},
    {district: 24, twitter: 'DavidWeprin'},
    {district: 25, twitter: 'nily'},
    {district: 26, twitter: 'edbraunstein'},
    {district: 27, twitter: 'MikeSimanowitz'},
    {district: 28, twitter: 'AndrewHevesi'},
    {district: 29, twitter: 'AliciaHyndman'},
    {district: 30, twitter: 'Barnwell30'},
    {district: 31, twitter: nil},
    {district: 32, twitter: nil},
    {district: 33, twitter: 'clydevanel'},
    {district: 34, twitter: 'mgdendekker'},
    {district: 35, twitter: nil},
    {district: 36, twitter: 'AravellaSimotas'},
    {district: 37, twitter: nil},
    {district: 38, twitter: 'assemblymanmike'},
    {district: 39, twitter: 'FranciscoPMoya'},
    {district: 40, twitter: 'rontkim'},
    {district: 41, twitter: 'HeleneWeinstein'},
    {district: 42, twitter: 'AMBichotte'},
    {district: 43, twitter: 'Vote_Richardson'},
    {district: 44, twitter: 'Bobby4Brooklyn'},
    {district: 45, twitter: 'SteveCym'},
    {district: 46, twitter: 'AMPamelaHarris'},
    {district: 47, twitter: nil},
    {district: 48, twitter: 'HikindDov'},
    {district: 49, twitter: nil},
    {district: 50, twitter: 'assemblymanjoe'},
    {district: 51, twitter: 'Felixwortiz'},
    {district: 52, twitter: 'JoAnneSimonBK52'},
    {district: 53, twitter: 'DavilaAssembly'},
    {district: 54, twitter: 'edilan37'},
    {district: 55, twitter: 'AssemblyLWalker'},
    {district: 56, twitter: 'wrightnys56ad'},
    {district: 57, twitter: 'WalterTMosley'},
    {district: 58, twitter: 'NNickPerry'},
    {district: 59, twitter: nil},
    {district: 60, twitter: 'CharlesBarron12'},
    {district: 61, twitter: 'MatthewTitone'},
    {district: 62, twitter: 'RonCastorina'},
    {district: 63, twitter: 'Michael_Cusick'},
    {district: 64, twitter: 'NMalliotakis'},
    {district: 65, twitter: 'yuhline'},
    {district: 66, twitter: 'DeborahJGlick'},
    {district: 67, twitter: 'LindaBRosenthal'},
    {district: 68, twitter: '_rjayrodriguez'},
    {district: 69, twitter: 'DanielJODonnell'},
    {district: 70, twitter: 'Dickens4NewYork'},
    {district: 71, twitter: 'dennyfarrell71a'},
    {district: 72, twitter: 'CnDelarosa'},
    {district: 73, twitter: 'DanQuartNY'},
    {district: 74, twitter: 'BrianKavanaghNY'},
    {district: 75, twitter: 'DickGottfried'},
    {district: 76, twitter: 'SeawrightForNY' },
    {district: 77, twitter: 'JoinJoyner'},
    {district: 78, twitter: 'RevolutionJR'},
    {district: 79, twitter: 'MrMikeBlake'},
    {district: 80, twitter: 'MarkGjonaj80'},
    {district: 81, twitter: 'JeffreyDinowitz'},
    {district: 82, twitter: nil},
    {district: 83, twitter: 'CarlHeastie'},
    {district: 84, twitter: nil},
    {district: 85, twitter: 'MarcosCrespo85'},
    {district: 86, twitter: 'Vpichardo86'},
    {district: 87, twitter: 'LuisSepulvedaNY'},
    {district: 88, twitter: 'AmyPaulin'},
    {district: 89, twitter: 'JGPretlow'},
    {district: 90, twitter: 'shelleybmayer'},
    {district: 91, twitter: 'SteveOtis91'},
    {district: 92, twitter: 'TomAbinanti'},
    {district: 93, twitter: 'DavidBuchwald'},
    {district: 94, twitter: 'Byrne4NY'},
    {district: 95, twitter: 'SandyGalef'},
    {district: 96, twitter: 'kenzebrowski_ny'},
    {district: 97, twitter: 'EllenCJaffee'},
    {district: 98, twitter: 'KarlBrabenec'},
    {district: 99, twitter: 'JamesSkoufis'},
    {district: 100, twitter: 'AileenMGunther'},
    {district: 101, twitter: nil},
    {district: 102, twitter: nil},
    {district: 103, twitter: nil},
    {district: 104, twitter: 'FrankSkartados'},
    {district: 105, twitter: 'KieranLalor'},
    {district: 106, twitter: 'Didi4Assembly'},
    {district: 107, twitter: 'SteveMcNY'},
    {district: 108, twitter: 'johnmcdonald108'},
    {district: 109, twitter: 'PatriciaFahy109'},
    {district: 110, twitter: 'PhilSteck'},
    {district: 111, twitter: 'AsmSantabarbara'},
    {district: 112, twitter: 'MBWalsh112'},
    {district: 113, twitter: 'AMCarrieWoerner'},
    {district: 114, twitter: 'danstec'},
    {district: 115, twitter: 'jonesnyassembly'},
    {district: 116, twitter: 'AddieJenne'},
    {district: 117, twitter: 'kblankenbush'},
    {district: 118, twitter: nil},
    {district: 119, twitter: 'ABrindisi119' },
    {district: 120, twitter: 'WillABarclay'},
    {district: 121, twitter: nil},
    {district: 122, twitter: nil},
    {district: 123, twitter: 'donnalupardo'},
    {district: 124, twitter: 'Friend4Assembly'},
    {district: 125, twitter: 'AssemblywomanLi'},
    {district: 126, twitter: nil},
    {district: 127, twitter: 'StirpeAl'},
    {district: 128, twitter: 'PamelaHunter128'},
    {district: 129, twitter: 'BillMagnarelli'},
    {district: 130, twitter: nil},
    {district: 131, twitter: 'GOPLdrBrianKolb'},
    {district: 132, twitter: 'PhilPalmesano'},
    {district: 133, twitter: nil},
    {district: 134, twitter: 'PLawrence134th'},
    {district: 135, twitter: 'MarkJohns_135th'},
    {district: 136, twitter: 'JoeMorelle'},
    {district: 137, twitter: nil},
    {district: 138, twitter: 'HarryBBronson'},
    {district: 139, twitter: 'SteveMHawley'},
    {district: 140, twitter: nil},
    {district: 141, twitter: 'CPeoplesStokes'},
    {district: 142, twitter: 'Mickey_Kearns'},
    {district: 143, twitter: 'mwallace143'},
    {district: 144, twitter: 'Mike_Norris_144'},
    {district: 145, twitter: 'VoteJudgeAngelo'},
    {district: 146, twitter: 'RaymondWWalter'},
    {district: 147, twitter: 'DiPietro4NY'},
    {district: 148, twitter: nil},
    {district: 149, twitter: 'SeanMRyan149'},
    {district: 150, twitter: 'andygoodell'}
  ]
end

def joining
  joiner = []
  ny_senate_twitters.each { |tw| 
    leg = Legislator.all.find_by(chamber: "Senate", district: tw[:district])
    joiner << {district: tw[:district], twitter: tw[:twitter], web_name: tw[:web_name], db_name: leg.name} 
  }
end


def export_to_csv

  require 'csv'

  actions = Action.all
  calls = Call.all
  call_lists = CallList.all
  campaigns = Campaign.all

  ref = [
    {
      file: "./actions.csv",
      headers: ["id", "campaign_id", "user_id", "legislator_id", "kind", "status", "complete", "date"],
      array: actions 
    },
    {
      file: "./calls.csv",
      headers: ["id", "action_id", "outcome", "commitment", "duration", "notes", "call_list_id"],
      array: calls  
    },
    {
      file: "./call_lists.csv",
      headers: ["id", "campaign_id", "name"],
      array: call_lists  
    },
    {
      file: "./campaigns.csv",
      headers: ["id", "name", "user_id"],
      array: campaigns  
    }
  ]

  ref.each do |table|
    CSV.open(table[:file], 'w', write_headers: true, headers: table[:headers]) do |writer|
      table[:array].each do |record|
        record_array = []
        table[:headers].each do |field|
          record_array << record[field]
        end
        writer << record_array
      end
    end
  end

end

def delete_user_data_but_not_users
  Call.all.delete_all  
  CallList.all.delete_all  
  Action.all.delete_all 
end

