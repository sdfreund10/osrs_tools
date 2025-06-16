# #region Update Player
# curl -X POST https://api.wiseoldman.net/v2/players/zezima -H "Content-Type: application/json"
# {
#   "id": 1135,
#   "username": "zezima",
#   "displayName": "Zezima",
#   "type": "regular",
#   "build": "main",
#   "country": null,
#   "status": "active",
#   "patron": false,
#   "exp": 27957906,
#   "ehp": 118.1123000000007,
#   "ehb": 0,
#   "ttm": 891.24136,
#   "tt200m": 13406.30792,
#   "registeredAt": "2020-04-22T18:54:52.487Z",
#   "updatedAt": "2022-10-27T11:44:11.564Z",
#   "lastChangedAt": "2021-04-17T15:57:49.039Z",
#   "lastImportedAt": "2022-10-23T18:24:22.792Z",
#   "combatLevel": 93,
#   "archive": null,
#   "annotations": [
#     {
#       "playerId": 1135,
#       "type": "opt_out",
#       "createdAt": "2025-01-13T17:08:35.534Z"
#     }
#   ],
#   "latestSnapshot": {
#     "id": 68052294,
#     "playerId": 1135,
#     "createdAt": "2022-10-27T11:44:11.057Z",
#     "importedAt": null,
#     "data": {
#       "skills": {
#         "overall": {
#           "metric": "overall",
#           "experience": 27957906,
#           "rank": 948821,
#           "level": 1422,
#           "ehp": 118.1123000000007
#         }
#         // ... etc for all skills
#       },
#       "bosses": {
#         "abyssal_sire": {
#           "metric": "abyssal_sire",
#           "kills": -1,
#           "rank": -1,
#           "ehb": 0
#         }
#         // ... etc for all bosses
#       },
#       "activities": {
#         "bounty_hunter_hunter": {
#           "metric": "bounty_hunter_hunter",
#           "score": -1,
#           "rank": -1
#         }
#         // ... etc for all activities
#       },
#       "computed": {
#         "ehp": {
#           "metric": "ehp",
#           "value": 118.1123000000007,
#           "rank": 289382
#         }
#         // ... etc for all computed metrics
#       }
#     }
#   }
# }

# region Get Gains
# curl -X GET https://api.wiseoldman.net/v2/players/zezima/gained?period=week -H "Content-Type: application/json"
# {
#   "startsAt": "2022-10-21T16:06:00.993Z",
#   "endsAt": "2022-10-24T00:19:46.350Z",
#   "data": {
#     "skills": {
#       "overall": {
#         "metric": "overall",
#         "experience": {
#           "gained": 90867,
#           "start": 131790911,
#           "end": 131881778
#         },
#         "ehp": {
#           "gained": 0.04787,
#           "start": 251.14464000000044,
#           "end": 251.19251000000077
#         },
#         "rank": {
#           "gained": 478,
#           "start": 308702,
#           "end": 309180
#         },
#         "level": {
#           "gained": 0,
#           "start": 1902,
#           "end": 1902
#         }
#       }
#       // ... etc for all skills
#     },
#     "bosses": {
#       "abyssal_sire": {
#         "metric": "abyssal_sire",
#         "ehb": {
#           "gained": 0,
#           "start": 0,
#           "end": 0
#         },
#         "rank": {
#           "gained": -1,
#           "start": -1,
#           "end": -1
#         },
#         "kills": {
#           "gained": 0,
#           "start": -1,
#           "end": -1
#         }
#       }
#       // ... etc for all bosses
#     },
#     "activities": {
#       "bounty_hunter_hunter": {
#         "metric": "bounty_hunter_hunter",
#         "rank": {
#           "gained": -1,
#           "start": -1,
#           "end": -1
#         },
#         "score": {
#           "gained": 0,
#           "start": -1,
#           "end": -1
#         }
#       }
#       // ... etc for all activities
#     },
#     "computed": {
#       "ehp": {
#         "metric": "ehp",
#         "value": {
#           "gained": 0.04787,
#           "start": 251.14464000000044,
#           "end": 251.19251000000077
#         },
#         "rank": {
#           "gained": 386,
#           "start": 171375,
#           "end": 171761
#         }
#       }
#       // ... etc for all computed metrics
#     }
#   }
# }
