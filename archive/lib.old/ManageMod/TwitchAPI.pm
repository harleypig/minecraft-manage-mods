package ManageMod::TwitchAPI;

## no critic

# Source for Twitch App API at https://github.com/Gaz492/TwitchAPI
# Also, see https://twitchapi.docs.apiary.io/

use strictures 2;
use namespace::clean;

use parent 'Exporter::Tiny';

our @EXPORT = qw(XXX);

use Log::Any '$log';

use ManageMod::GetData;
use ManageMod::Cache;

our $BASE_URL='https://addons-ecs.forgesvc.net';
our $API_URL="$BASE_URL/api/v2";
our $ADDON_URL="$API_URL/addon";

sub _verify_int {
  $_[0] =~ /^\d+$/ && return 1;
  warn $log->fatalf('%s is not an integer', $addon_id);
  return 0;
}

sub new {
  my ( $class, $args ) = @_;

  die 'new for ManageMod::TwitchAPI requires hash ref'
    if defined $args && ref $args ne 'HASH';

  $args //= {};

  return bless $args, $class;
}

##############################################################################
# API Methods
#
# addonID - integer
# fileID - integer
# categoryID - integer
#
#-----------------------------------------------------------------------------
## Get Addon Info [/api/v2/addon/{addonID}]
### Get Addon Info [GET]
#+ Response 200 (application/json)

sub addon_info {
  my ( $self, $addon_id ) = @_;
  return 0 unless _verify_int($addon_id);
  my $url = "$ADDON_URL/$addon_id";
  return get_json($url);
}

#-----------------------------------------------------------------------------
## Get Addon Description [/api/v2/addon/{addonID}/description]
sub addon_description {
  my ( $self, $addon_id ) = @_;
  return 0 unless _verify_int($addon_id);
  my $url = "$ADDON_URL/$addon_id/description";
  return get_json($url);
}

#-----------------------------------------------------------------------------


## Get Multiple Addons [/api/v2/addon]

### Get Multiple Addons [POST]

+ Request (application/json)

        [
                310806,
                304026
        ]

+ Response 200 (application/json)

        [
        {
                "id": 304026,
                "name": "Exact Spawn",
                "authors": [
                {
                        "name": "Gaz492",
                        "url": "https://www.curseforge.com/members/6881422-gaz492?username=Gaz492",
                        "projectId": 304026,
                        "id": 204866,
                        "projectTitleId": null,
                        "projectTitleTitle": null,
                        "userId": 6881422,
                        "twitchId": 24371401
                }
                ],
                "attachments": [
                {
                        "id": 172929,
                        "projectId": 304026,
                        "description": "",
                        "isDefault": true,
                        "thumbnailUrl": "https://media.forgecdn.net/avatars/thumbnails/172/929/256/256/636740081071795485.png",
                        "title": "636740081071795485.png",
                        "url": "https://media.forgecdn.net/avatars/172/929/636740081071795485.png",
                        "status": 1
                },
                {
                        "id": 237995,
                        "projectId": 304026,
                        "description": "",
                        "isDefault": false,
                        "thumbnailUrl": "https://media.forgecdn.net/attachments/thumbnails/237/995/310/172/java_2018-10-01_22-17-26.png",
                        "title": "After",
                        "url": "https://media.forgecdn.net/attachments/237/995/java_2018-10-01_22-17-26.png",
                        "status": 1
                },
                {
                        "id": 237994,
                        "projectId": 304026,
                        "description": "",
                        "isDefault": false,
                        "thumbnailUrl": "https://media.forgecdn.net/attachments/thumbnails/237/994/310/172/java_2018-10-01_22-01-32.png",
                        "title": "Before",
                        "url": "https://media.forgecdn.net/attachments/237/994/java_2018-10-01_22-01-32.png",
                        "status": 1
                }
                ],
                "websiteUrl": "https://www.curseforge.com/minecraft/mc-mods/exact-spawn",
                "gameId": 432,
                "summary": "Spawns the player at the exact world spawn",
                "defaultFileId": 2676102,
                "downloadCount": 121562,
                "latestFiles": [
                {
                        "id": 2676102,
                        "displayName": "ExactSpawn-1.12-1.2.3.17.jar",
                        "fileName": "ExactSpawn-1.12-1.2.3.17.jar",
                        "fileDate": "2019-02-17T21:53:45.933Z",
                        "fileLength": 12495,
                        "releaseType": 1,
                        "fileStatus": 4,
                        "downloadUrl": "https://edge.forgecdn.net/files/2676/102/ExactSpawn-1.12-1.2.3.17.jar",
                        "isAlternate": false,
                        "alternateFileId": 0,
                        "dependencies": [],
                        "isAvailable": true,
                        "modules": [
                        {
                                "foldername": "META-INF",
                                "fingerprint": 3415676226,
                                "type": 3
                        },
                        {
                                "foldername": "uk",
                                "fingerprint": 2854879410,
                                "type": 3
                        },
                        {
                                "foldername": "pack.mcmeta",
                                "fingerprint": 3273911401,
                                "type": 3
                        },
                        {
                                "foldername": "assets",
                                "fingerprint": 1508881524,
                                "type": 3
                        },
                        {
                                "foldername": "mcmod.info",
                                "fingerprint": 2275652206,
                                "type": 3
                        }
                        ],
                        "packageFingerprint": 1472556754,
                        "gameVersion": [
                        "1.12.2"
                        ],
                        "sortableGameVersion": [
                        {
                                "gameVersionPadded": "0000000001.0000000012.0000000002",
                                "gameVersion": "1.12.2",
                                "gameVersionReleaseDate": "2017-09-18T05:00:00Z",
                                "gameVersionName": "1.12.2"
                        }
                        ],
                        "installMetadata": null,
                        "changelog": null,
                        "hasInstallScript": false,
                        "isCompatibleWithClient": false,
                        "categorySectionPackageType": 6,
                        "restrictProjectFileAccess": 1,
                        "projectStatus": 4,
                        "renderCacheId": 1517881,
                        "fileLegacyMappingId": null,
                        "projectId": 304026,
                        "parentProjectFileId": null,
                        "parentFileLegacyMappingId": null,
                        "fileTypeId": null,
                        "exposeAsAlternative": null,
                        "packageFingerprintId": 294339471,
                        "gameVersionDateReleased": "2008-03-01T06:00:00Z",
                        "gameVersionMappingId": 1756629,
                        "gameVersionId": 4458,
                        "gameId": 432,
                        "isServerPack": false,
                        "serverPackFileId": null
                }
                ],
                "categories": [
                {
                        "categoryId": 425,
                        "name": "Miscellaneous",
                        "url": "https://www.curseforge.com/minecraft/mc-mods/mc-miscellaneous",
                        "avatarUrl": "https://media.forgecdn.net/avatars/6/40/635351497693711265.png",
                        "parentId": 6,
                        "rootId": 6,
                        "projectId": 304026,
                        "avatarId": 6040,
                        "gameId": 432
                },
                {
                        "categoryId": 423,
                        "name": "Map and Information",
                        "url": "https://www.curseforge.com/minecraft/mc-mods/map-information",
                        "avatarUrl": "https://media.forgecdn.net/avatars/6/38/635351497437388438.png",
                        "parentId": 6,
                        "rootId": 6,
                        "projectId": 304026,
                        "avatarId": 6038,
                        "gameId": 432
                },
                {
                        "categoryId": 435,
                        "name": "Server Utility",
                        "url": "https://www.curseforge.com/minecraft/mc-mods/server-utility",
                        "avatarUrl": "https://media.forgecdn.net/avatars/6/48/635351498950580836.png",
                        "parentId": 6,
                        "rootId": 6,
                        "projectId": 304026,
                        "avatarId": 6048,
                        "gameId": 432
                }
                ],
                "status": 4,
                "primaryCategoryId": 425,
                "categorySection": {
                "id": 8,
                "gameId": 432,
                "name": "Mods",
                "packageType": 6,
                "path": "mods",
                "initialInclusionPattern": ".",
                "extraIncludePattern": null,
                "gameCategoryId": 6
                },
                "slug": "exact-spawn",
                "gameVersionLatestFiles": [
                {
                        "gameVersion": "1.12.2",
                        "projectFileId": 2676102,
                        "projectFileName": "ExactSpawn-1.12-1.2.3.17.jar",
                        "fileType": 1
                }
                ],
                "isFeatured": false,
                "popularityScore": 715.268310546875,
                "gamePopularityRank": 1284,
                "primaryLanguage": "enUS",
                "gameSlug": "minecraft",
                "gameName": "Minecraft",
                "portalName": "www.curseforge.com",
                "dateModified": "2019-02-17T21:57:58.573Z",
                "dateCreated": "2018-10-01T16:28:27.133Z",
                "dateReleased": "2019-02-17T21:53:45.933Z",
                "isAvailable": true,
                "isExperiemental": false
        },
        {
                "id": 310806,
                "name": "Watermark",
                "authors": [
                {
                        "name": "Gaz492",
                        "url": "https://www.curseforge.com/members/6881422-gaz492?username=Gaz492",
                        "projectId": 310806,
                        "id": 212316,
                        "projectTitleId": null,
                        "projectTitleTitle": null,
                        "userId": 6881422,
                        "twitchId": 24371401
                }
                ],
                "attachments": [
                {
                        "id": 185018,
                        "projectId": 310806,
                        "description": "",
                        "isDefault": true,
                        "thumbnailUrl": "https://media.forgecdn.net/avatars/thumbnails/185/18/256/256/636824897396091696.png",
                        "title": "636824897396091696.png",
                        "url": "https://media.forgecdn.net/avatars/185/18/636824897396091696.png",
                        "status": 1
                },
                {
                        "id": 244016,
                        "projectId": 310806,
                        "description": "",
                        "isDefault": false,
                        "thumbnailUrl": "https://media.forgecdn.net/attachments/thumbnails/244/16/310/172/java_2019-01-07_20-29-48.png",
                        "title": "Example",
                        "url": "https://media.forgecdn.net/attachments/244/16/java_2019-01-07_20-29-48.png",
                        "status": 1
                }
                ],
                "websiteUrl": "https://www.curseforge.com/minecraft/mc-mods/watermark",
                "gameId": 432,
                "summary": "Shows watermark on top centre screen",
                "defaultFileId": 2657461,
                "downloadCount": 195,
                "latestFiles": [
                {
                        "id": 2657461,
                        "displayName": "Watermark-1.12-1.0.jar",
                        "fileName": "Watermark-1.12-1.0.jar",
                        "fileDate": "2019-01-07T20:37:37.717Z",
                        "fileLength": 9097,
                        "releaseType": 1,
                        "fileStatus": 4,
                        "downloadUrl": "https://edge.forgecdn.net/files/2657/461/Watermark-1.12-1.0.jar",
                        "isAlternate": false,
                        "alternateFileId": 0,
                        "dependencies": [],
                        "isAvailable": true,
                        "modules": [
                        {
                                "foldername": "META-INF",
                                "fingerprint": 1774297949,
                                "type": 3
                        },
                        {
                                "foldername": "uk",
                                "fingerprint": 3536121930,
                                "type": 3
                        },
                        {
                                "foldername": "mcmod.info",
                                "fingerprint": 1697886471,
                                "type": 3
                        },
                        {
                                "foldername": "pack.mcmeta",
                                "fingerprint": 3273911401,
                                "type": 3
                        }
                        ],
                        "packageFingerprint": 3028671922,
                        "gameVersion": [
                        "1.12.2"
                        ],
                        "sortableGameVersion": [
                        {
                                "gameVersionPadded": "0000000001.0000000012.0000000002",
                                "gameVersion": "1.12.2",
                                "gameVersionReleaseDate": "2017-09-18T05:00:00Z",
                                "gameVersionName": "1.12.2"
                        }
                        ],
                        "installMetadata": null,
                        "changelog": null,
                        "hasInstallScript": false,
                        "isCompatibleWithClient": false,
                        "categorySectionPackageType": 6,
                        "restrictProjectFileAccess": 1,
                        "projectStatus": 4,
                        "renderCacheId": 1495256,
                        "fileLegacyMappingId": null,
                        "projectId": 310806,
                        "parentProjectFileId": null,
                        "parentFileLegacyMappingId": null,
                        "fileTypeId": null,
                        "exposeAsAlternative": null,
                        "packageFingerprintId": 285264201,
                        "gameVersionDateReleased": "2017-09-18T05:00:00Z",
                        "gameVersionMappingId": 1729095,
                        "gameVersionId": 6756,
                        "gameId": 432,
                        "isServerPack": false,
                        "serverPackFileId": null
                }
                ],
                "categories": [
                {
                        "categoryId": 424,
                        "name": "Cosmetic",
                        "url": "https://www.curseforge.com/minecraft/mc-mods/cosmetic",
                        "avatarUrl": "https://media.forgecdn.net/avatars/6/39/635351497555976928.png",
                        "parentId": 6,
                        "rootId": 6,
                        "projectId": 310806,
                        "avatarId": 6039,
                        "gameId": 432
                },
                {
                        "categoryId": 423,
                        "name": "Map and Information",
                        "url": "https://www.curseforge.com/minecraft/mc-mods/map-information",
                        "avatarUrl": "https://media.forgecdn.net/avatars/6/38/635351497437388438.png",
                        "parentId": 6,
                        "rootId": 6,
                        "projectId": 310806,
                        "avatarId": 6038,
                        "gameId": 432
                }
                ],
                "status": 4,
                "primaryCategoryId": 424,
                "categorySection": {
                "id": 8,
                "gameId": 432,
                "name": "Mods",
                "packageType": 6,
                "path": "mods",
                "initialInclusionPattern": ".",
                "extraIncludePattern": null,
                "gameCategoryId": 6
                },
                "slug": "watermark",
                "gameVersionLatestFiles": [
                {
                        "gameVersion": "1.12.2",
                        "projectFileId": 2657461,
                        "projectFileName": "Watermark-1.12-1.0.jar",
                        "fileType": 1
                }
                ],
                "isFeatured": false,
                "popularityScore": 15.070099830627441,
                "gamePopularityRank": 19923,
                "primaryLanguage": "enUS",
                "gameSlug": "minecraft",
                "gameName": "Minecraft",
                "portalName": "www.curseforge.com",
                "dateModified": "2019-06-09T22:28:36.883Z",
                "dateCreated": "2019-01-07T20:28:59.577Z",
                "dateReleased": "2019-01-07T20:37:37.717Z",
                "isAvailable": true,
                "isExperiemental": false
        }
        ]


## Twitch addon search [/api/v2/addon/search?categoryId={categoryID}&gameId={gameId}&gameVersion={gameVersion}&index={index}&pageSize={pageSize}5&searchFilter={searchFilter}&sectionId={sectionId}&sort={sort}]
### Twitch addon search [GET]
+ Parameters
    + categoryID: `0` (integer)
    + gameId: `432` (integer)
    + gameVersion: `1.12.2` (string)
    + index: `0` (integer)
    + pageSize: `25` (integer)
    + searchFilter: `ultimate` (string)
    + sectionId: `4471` (integer)
    + sort: `0` (integer)

+ Response 200 (application/json)

            [
                {
                    "id": 281999,
                    "name": "FTB Presents Direwolf20 1.12",
                    "authors": [
                        {
                            "name": "FTB",
                            "url": "https://www.curseforge.com/members/17809311-ftb?username=FTB",
                            "projectId": 281999,
                            "id": 180303,
                            "projectTitleId": null,
                            "projectTitleTitle": null,
                            "userId": 17809311,
                            "twitchId": 151020426
                        }
                    ],
                    "attachments": [
                        {
                            "id": 130869,
                            "projectId": 281999,
                            "description": "",
                            "isDefault": true,
                            "thumbnailUrl": "https://media.forgecdn.net/avatars/thumbnails/130/869/256/256/636463423723532339.png",
                            "title": "636463423723532339.png",
                            "url": "https://media.forgecdn.net/avatars/130/869/636463423723532339.png",
                            "status": 1
                        }
                    ],
                    "websiteUrl": "https://www.curseforge.com/minecraft/modpacks/ftb-presents-direwolf20-1-12",
                    "gameId": 432,
                    "summary": "Play along with Direwolf20 in this FTB pack curated and designed to match his 1.12.2 YouTube series.",
                    "defaultFileId": 2690085,
                    "downloadCount": 1188041,
                    "latestFiles": [
                        {
                            "id": 2637177,
                            "displayName": "FTBPresentsDirewolf20112-2.4.0-1.12.2.zip",
                            "fileName": "FTBPresentsDirewolf20112-2.4.0-1.12.2.zip",
                            "fileDate": "2018-11-11T13:43:50.897Z",
                            "fileLength": 14903086,
                            "releaseType": 2,
                            "fileStatus": 4,
                            "downloadUrl": "https://edge.forgecdn.net/files/2637/177/FTBPresentsDirewolf20112-2.4.0-1.12.2.zip",
                            "isAlternate": false,
                            "alternateFileId": 0,
                            "dependencies": [],
                            "isAvailable": true,
                            "modules": [
                                {
                                    "foldername": "manifest.json",
                                    "fingerprint": 3349980719,
                                    "type": 3
                                }
                            ],
                            "packageFingerprint": 1129432111,
                            "gameVersion": [
                                "1.12.2"
                            ],
                            "sortableGameVersion": [
                                {
                                    "gameVersionPadded": "0000000001.0000000012.0000000002",
                                    "gameVersion": "1.12.2",
                                    "gameVersionReleaseDate": "2017-09-18T05:00:00Z",
                                    "gameVersionName": "1.12.2"
                                }
                            ],
                            "installMetadata": null,
                            "changelog": null,
                            "hasInstallScript": false,
                            "isCompatibleWithClient": true,
                            "categorySectionPackageType": 5,
                            "restrictProjectFileAccess": 1,
                            "projectStatus": 4,
                            "renderCacheId": 1470968,
                            "fileLegacyMappingId": null,
                            "projectId": 281999,
                            "parentProjectFileId": null,
                            "parentFileLegacyMappingId": null,
                            "fileTypeId": null,
                            "exposeAsAlternative": null,
                            "packageFingerprintId": 275097203,
                            "gameVersionDateReleased": "2017-09-18T05:00:00Z",
                            "gameVersionMappingId": 1697294,
                            "gameVersionId": 6756,
                            "gameId": 432,
                            "isServerPack": false,
                            "serverPackFileId": null
                        },
                        {
                            "id": 2690085,
                            "displayName": "FTBPresentsDirewolf20112-2.5.0-1.12.2.zip",
                            "fileName": "FTBPresentsDirewolf20112-2.5.0-1.12.2.zip",
                            "fileDate": "2019-03-21T19:55:41.91Z",
                            "fileLength": 15126488,
                            "releaseType": 1,
                            "fileStatus": 4,
                            "downloadUrl": "https://edge.forgecdn.net/files/2690/85/FTBPresentsDirewolf20112-2.5.0-1.12.2.zip",
                            "isAlternate": false,
                            "alternateFileId": 0,
                            "dependencies": [],
                            "isAvailable": true,
                            "modules": [
                                {
                                    "foldername": "manifest.json",
                                    "fingerprint": 4176987902,
                                    "type": 3
                                }
                            ],
                            "packageFingerprint": 198388120,
                            "gameVersion": [
                                "1.12.2"
                            ],
                            "sortableGameVersion": [
                                {
                                    "gameVersionPadded": "0000000001.0000000012.0000000002",
                                    "gameVersion": "1.12.2",
                                    "gameVersionReleaseDate": "2017-09-18T05:00:00Z",
                                    "gameVersionName": "1.12.2"
                                }
                            ],
                            "installMetadata": null,
                            "changelog": null,
                            "hasInstallScript": false,
                            "isCompatibleWithClient": true,
                            "categorySectionPackageType": 5,
                            "restrictProjectFileAccess": 1,
                            "projectStatus": 4,
                            "renderCacheId": 1534902,
                            "fileLegacyMappingId": null,
                            "projectId": 281999,
                            "parentProjectFileId": null,
                            "parentFileLegacyMappingId": null,
                            "fileTypeId": null,
                            "exposeAsAlternative": null,
                            "packageFingerprintId": 302233456,
                            "gameVersionDateReleased": "2017-09-18T05:00:00Z",
                            "gameVersionMappingId": 1776729,
                            "gameVersionId": 6756,
                            "gameId": 432,
                            "isServerPack": false,
                            "serverPackFileId": 2690320
                        }
                    ],
                    "categories": [
                        {
                            "categoryId": 4482,
                            "name": "Extra Large",
                            "url": "https://www.curseforge.com/minecraft/modpacks/extra-large",
                            "avatarUrl": "https://media.forgecdn.net/avatars/14/472/635596760403562826.png",
                            "parentId": 4471,
                            "rootId": 4471,
                            "projectId": 281999,
                            "avatarId": 14472,
                            "gameId": 432
                        },
                        {
                            "categoryId": 4487,
                            "name": "FTB Official Pack",
                            "url": "https://www.curseforge.com/minecraft/modpacks/ftb-official-pack",
                            "avatarUrl": "https://media.forgecdn.net/avatars/15/166/635616941825349689.png",
                            "parentId": 4471,
                            "rootId": 4471,
                            "projectId": 281999,
                            "avatarId": 15166,
                            "gameId": 432
                        },
                        {
                            "categoryId": 4473,
                            "name": "Magic",
                            "url": "https://www.curseforge.com/minecraft/modpacks/magic",
                            "avatarUrl": "https://media.forgecdn.net/avatars/14/474/635596760578719019.png",
                            "parentId": 4471,
                            "rootId": 4471,
                            "projectId": 281999,
                            "avatarId": 14474,
                            "gameId": 432
                        },
                        {
                            "categoryId": 4472,
                            "name": "Tech",
                            "url": "https://www.curseforge.com/minecraft/modpacks/tech",
                            "avatarUrl": "https://media.forgecdn.net/avatars/14/479/635596761534662757.png",
                            "parentId": 4471,
                            "rootId": 4471,
                            "projectId": 281999,
                            "avatarId": 14479,
                            "gameId": 432
                        }
                    ],
                    "status": 4,
                    "primaryCategoryId": 4472,
                    "categorySection": {
                        "id": 11,
                        "gameId": 432,
                        "name": "Modpacks",
                        "packageType": 5,
                        "path": "downloads",
                        "initialInclusionPattern": "$^",
                        "extraIncludePattern": null,
                        "gameCategoryId": 4471
                    },
                    "slug": "ftb-presents-direwolf20-1-12",
                    "gameVersionLatestFiles": [
                        {
                            "gameVersion": "1.12.2",
                            "projectFileId": 2690085,
                            "projectFileName": "FTBPresentsDirewolf20112-2.5.0-1.12.2.zip",
                            "fileType": 1
                        },
                        {
                            "gameVersion": "1.12.2",
                            "projectFileId": 2637177,
                            "projectFileName": "FTBPresentsDirewolf20112-2.4.0-1.12.2.zip",
                            "fileType": 2
                        }
                    ],
                    "isFeatured": true,
                    "popularityScore": 9125.0888671875,
                    "gamePopularityRank": 953,
                    "primaryLanguage": "enUS",
                    "gameSlug": "minecraft",
                    "gameName": "Minecraft",
                    "portalName": "www.curseforge.com",
                    "dateModified": "2019-04-02T16:57:02.287Z",
                    "dateCreated": "2017-11-15T17:32:52.227Z",
                    "dateReleased": "2019-03-22T13:41:10.9Z",
                    "isAvailable": true,
                    "isExperiemental": false
                },
                {
                    "id": 317871,
                    "name": "FTB Interactions",
                    "authors": [
                        {
                            "name": "FTB",
                            "url": "https://www.curseforge.com/members/17809311-ftb?username=FTB",
                            "projectId": 317871,
                            "id": 220128,
                            "projectTitleId": 38,
                            "projectTitleTitle": "Author",
                            "userId": 17809311,
                            "twitchId": 151020426
                        }
                    ],
                    "attachments": [
                        {
                            "id": 196825,
                            "projectId": 317871,
                            "description": "",
                            "isDefault": true,
                            "thumbnailUrl": "https://media.forgecdn.net/avatars/thumbnails/196/825/256/256/636888012194151974.png",
                            "title": "636888012194151974.png",
                            "url": "https://media.forgecdn.net/avatars/196/825/636888012194151974.png",
                            "status": 1
                        }
                    ],
                    "websiteUrl": "https://www.curseforge.com/minecraft/modpacks/ftb-interactions",
                    "gameId": 432,
                    "summary": "Do you want to traverse the dark star Aurelia, scavenging it's dungeons for rare technology while fighting off Eldritch Praetors? How about draining the blue vitriol oceans of Euclydes to feed the copper consumption of your increasingly large factories?...",
                    "defaultFileId": 2714053,
                    "downloadCount": 170057,
                    "latestFiles": [
                        {
                            "id": 2712050,
                            "displayName": "FTBInteractions-1.6.1-1.12.2.zip",
                            "fileName": "FTBInteractions-1.6.1-1.12.2.zip",
                            "fileDate": "2019-05-16T21:25:47.823Z",
                            "fileLength": 78966058,
                            "releaseType": 2,
                            "fileStatus": 4,
                            "downloadUrl": "https://edge.forgecdn.net/files/2712/50/FTBInteractions-1.6.1-1.12.2.zip",
                            "isAlternate": false,
                            "alternateFileId": 0,
                            "dependencies": [],
                            "isAvailable": true,
                            "modules": [
                                {
                                    "foldername": "manifest.json",
                                    "fingerprint": 3391416046,
                                    "type": 3
                                }
                            ],
                            "packageFingerprint": 3674381567,
                            "gameVersion": [
                                "1.12.2"
                            ],
                            "sortableGameVersion": [
                                {
                                    "gameVersionPadded": "0000000001.0000000012.0000000002",
                                    "gameVersion": "1.12.2",
                                    "gameVersionReleaseDate": "2017-09-18T05:00:00Z",
                                    "gameVersionName": "1.12.2"
                                }
                            ],
                            "installMetadata": null,
                            "changelog": null,
                            "hasInstallScript": false,
                            "isCompatibleWithClient": true,
                            "categorySectionPackageType": 5,
                            "restrictProjectFileAccess": 1,
                            "projectStatus": 4,
                            "renderCacheId": 1560807,
                            "fileLegacyMappingId": null,
                            "projectId": 317871,
                            "parentProjectFileId": null,
                            "parentFileLegacyMappingId": null,
                            "fileTypeId": null,
                            "exposeAsAlternative": null,
                            "packageFingerprintId": 316127458,
                            "gameVersionDateReleased": "2017-09-18T05:00:00Z",
                            "gameVersionMappingId": 1813538,
                            "gameVersionId": 6756,
                            "gameId": 432,
                            "isServerPack": false,
                            "serverPackFileId": 2712053
                        },
                        {
                            "id": 2714053,
                            "displayName": "FTBInteractions-1.7.0-1.12.2.zip",
                            "fileName": "FTBInteractions-1.7.0-1.12.2.zip",
                            "fileDate": "2019-05-21T14:01:53.907Z",
                            "fileLength": 79134597,
                            "releaseType": 1,
                            "fileStatus": 4,
                            "downloadUrl": "https://edge.forgecdn.net/files/2714/53/FTBInteractions-1.7.0-1.12.2.zip",
                            "isAlternate": false,
                            "alternateFileId": 0,
                            "dependencies": [],
                            "isAvailable": true,
                            "modules": [
                                {
                                    "foldername": "manifest.json",
                                    "fingerprint": 142251955,
                                    "type": 3
                                }
                            ],
                            "packageFingerprint": 3761165091,
                            "gameVersion": [
                                "1.12.2"
                            ],
                            "sortableGameVersion": [
                                {
                                    "gameVersionPadded": "0000000001.0000000012.0000000002",
                                    "gameVersion": "1.12.2",
                                    "gameVersionReleaseDate": "2017-09-18T05:00:00Z",
                                    "gameVersionName": "1.12.2"
                                }
                            ],
                            "installMetadata": null,
                            "changelog": null,
                            "hasInstallScript": false,
                            "isCompatibleWithClient": true,
                            "categorySectionPackageType": 5,
                            "restrictProjectFileAccess": 1,
                            "projectStatus": 4,
                            "renderCacheId": 1563229,
                            "fileLegacyMappingId": null,
                            "projectId": 317871,
                            "parentProjectFileId": null,
                            "parentFileLegacyMappingId": null,
                            "fileTypeId": null,
                            "exposeAsAlternative": null,
                            "packageFingerprintId": 317594365,
                            "gameVersionDateReleased": "2017-09-18T05:00:00Z",
                            "gameVersionMappingId": 1816808,
                            "gameVersionId": 6756,
                            "gameId": 432,
                            "isServerPack": false,
                            "serverPackFileId": 2714056
                        }
                    ],
                    "categories": [
                        {
                            "categoryId": 4479,
                            "name": "Hardcore",
                            "url": "https://www.curseforge.com/minecraft/modpacks/hardcore",
                            "avatarUrl": "https://media.forgecdn.net/avatars/14/473/635596760504656528.png",
                            "parentId": 4471,
                            "rootId": 4471,
                            "projectId": 317871,
                            "avatarId": 14473,
                            "gameId": 432
                        },
                        {
                            "categoryId": 4476,
                            "name": "Exploration",
                            "url": "https://www.curseforge.com/minecraft/modpacks/exploration",
                            "avatarUrl": "https://media.forgecdn.net/avatars/14/486/635596815896417213.png",
                            "parentId": 4471,
                            "rootId": 4471,
                            "projectId": 317871,
                            "avatarId": 14486,
                            "gameId": 432
                        },
                        {
                            "categoryId": 4487,
                            "name": "FTB Official Pack",
                            "url": "https://www.curseforge.com/minecraft/modpacks/ftb-official-pack",
                            "avatarUrl": "https://media.forgecdn.net/avatars/15/166/635616941825349689.png",
                            "parentId": 4471,
                            "rootId": 4471,
                            "projectId": 317871,
                            "avatarId": 15166,
                            "gameId": 432
                        },
                        {
                            "categoryId": 4472,
                            "name": "Tech",
                            "url": "https://www.curseforge.com/minecraft/modpacks/tech",
                            "avatarUrl": "https://media.forgecdn.net/avatars/14/479/635596761534662757.png",
                            "parentId": 4471,
                            "rootId": 4471,
                            "projectId": 317871,
                            "avatarId": 14479,
                            "gameId": 432
                        }
                    ],
                    "status": 4,
                    "primaryCategoryId": 4472,
                    "categorySection": {
                        "id": 11,
                        "gameId": 432,
                        "name": "Modpacks",
                        "packageType": 5,
                        "path": "downloads",
                        "initialInclusionPattern": "$^",
                        "extraIncludePattern": null,
                        "gameCategoryId": 4471
                    },
                    "slug": "ftb-interactions",
                    "gameVersionLatestFiles": [
                        {
                            "gameVersion": "1.12.2",
                            "projectFileId": 2714053,
                            "projectFileName": "FTBInteractions-1.7.0-1.12.2.zip",
                            "fileType": 1
                        },
                        {
                            "gameVersion": "1.12.2",
                            "projectFileId": 2712050,
                            "projectFileName": "FTBInteractions-1.6.1-1.12.2.zip",
                            "fileType": 2
                        }
                    ],
                    "isFeatured": true,
                    "popularityScore": 8240.3095703125,
                    "gamePopularityRank": 1020,
                    "primaryLanguage": "enUS",
                    "gameSlug": "minecraft",
                    "gameName": "Minecraft",
                    "portalName": "www.curseforge.com",
                    "dateModified": "2019-05-28T18:27:12.477Z",
                    "dateCreated": "2019-03-21T21:40:19.367Z",
                    "dateReleased": "2019-05-21T14:06:16.247Z",
                    "isAvailable": true,
                    "isExperiemental": false
                }
            ]

## Get Addon Description [/api/v2/addon/{addonID}/description]
### Get Addon Description [GET]

+ Parameters
    + addonID: `310806` (integer)

+ Response 200 (text/plain)

        <p>Shows a custom watermark in the top centre of the users screen.</p>
        <p>&nbsp;</p>
        <p><img src="https://media.forgecdn.net/attachments/244/16/java_2019-01-07_20-29-48.png" alt="" width="1920" height="1017"></p>
        <p>&nbsp;</p>
        <p>Example config:</p>
        <pre># Configuration file

        general {

            watermarkconfig {
                # Sets first line to be the player uuid
                B:Line1PlayerUUID=false
            }

            watermarkconfiglines {
                # Leave Blank To Ignore
                # Line 1 will be ignored if setLine1PlayerUUID is true
                S:Line1=
                S:Line2=
                S:Line3=
                S:Line4=
            }

            watermarkconfigtextcolour {
                I:Alpha=255
                I:Blue=255
                I:Green=255
                I:Red=255
            }

        }
        </pre>

## Get Addon File Changelog [/api/v2/addon/{addonID}/file/{fileID}/changelog]
### Get Addon File Changelog [GET]

+ Parameters
    + addonID: `310806` (integer)
    + fileID: `2657461` (integer)

+ Response 200 (text/plain)

        <p>Initial release</p>

## Get Addon File Information [/api/v2/addon/{addonID}/file/{fileID}]
### Get Addon File Information [GET]

+ Parameters
    + addonID: `310806` (integer)
    + fileID: `2657461` (integer)

+ Response 200 (application/json)

        {
            "id": 2657461,
            "displayName": "Watermark-1.12-1.0.jar",
            "fileName": "Watermark-1.12-1.0.jar",
            "fileDate": "2019-01-07T20:37:37.717Z",
            "fileLength": 9097,
            "releaseType": 1,
            "fileStatus": 4,
            "downloadUrl": "https://edge.forgecdn.net/files/2657/461/Watermark-1.12-1.0.jar",
            "isAlternate": false,
            "alternateFileId": 0,
            "dependencies": [],
            "isAvailable": true,
            "modules": [
                {
                    "foldername": "META-INF",
                    "fingerprint": 1774297949
                },
                {
                    "foldername": "uk",
                    "fingerprint": 3536121930
                },
                {
                    "foldername": "mcmod.info",
                    "fingerprint": 1697886471
                },
                {
                    "foldername": "pack.mcmeta",
                    "fingerprint": 3273911401
                }
            ],
            "packageFingerprint": 3028671922,
            "gameVersion": [
                "1.12.2"
            ],
            "installMetadata": null,
            "serverPackFileId": null,
            "hasInstallScript": false
        }

## Get Addon File Download URL [/api/v2/addon/{addonID}/file/{fileID}/download-url]
### Get Addon File Download URL [GET]

+ Parameters
    + addonID: `296062` (integer)
    + fileID: `2724357` (integer)

+ Response 200 (application/json)

        https://edge.forgecdn.net/files/2724/357/SkyFactory4-4.0.8.zip


## Get Addon Files [/api/v2/addon/{addonID}/files]
### Get Addon Files [GET]

+ Parameters
    + addonID: `304026` (integer)

+ Response 200 (application/json)

        [
            {
                "id": 2624589,
                "displayName": "ExactSpawn-1.12-1.1.6.jar",
                "fileName": "ExactSpawn-1.12-1.1.6.jar",
                "fileDate": "2018-10-05T15:35:34.6Z",
                "fileLength": 6469,
                "releaseType": 1,
                "fileStatus": 4,
                "downloadUrl": "https://edge.forgecdn.net/files/2624/589/ExactSpawn-1.12-1.1.6.jar",
                "isAlternate": false,
                "alternateFileId": 0,
                "dependencies": [],
                "isAvailable": true,
                "modules": [
                    {
                        "foldername": "META-INF",
                        "fingerprint": 1559573665
                    },
                    {
                        "foldername": "uk",
                        "fingerprint": 3723373003
                    },
                    {
                        "foldername": "mcmod.info",
                        "fingerprint": 3476837653
                    },
                    {
                        "foldername": "pack.mcmeta",
                        "fingerprint": 3273911401
                    }
                ],
                "packageFingerprint": 1637085566,
                "gameVersion": [
                    "1.12.2"
                ],
                "installMetadata": null,
                "serverPackFileId": null,
                "hasInstallScript": false
            },
            {
                "id": 2657107,
                "displayName": "ExactSpawn-1.12-1.2.2.15.jar",
                "fileName": "ExactSpawn-1.12-1.2.2.15.jar",
                "fileDate": "2019-01-06T19:50:45.373Z",
                "fileLength": 12401,
                "releaseType": 1,
                "fileStatus": 4,
                "downloadUrl": "https://edge.forgecdn.net/files/2657/107/ExactSpawn-1.12-1.2.2.15.jar",
                "isAlternate": false,
                "alternateFileId": 0,
                "dependencies": [],
                "isAvailable": true,
                "modules": [
                    {
                        "foldername": "META-INF",
                        "fingerprint": 1251018224
                    },
                    {
                        "foldername": "uk",
                        "fingerprint": 3988043351
                    },
                    {
                        "foldername": "pack.mcmeta",
                        "fingerprint": 3273911401
                    },
                    {
                        "foldername": "assets",
                        "fingerprint": 1508881524
                    },
                    {
                        "foldername": "mcmod.info",
                        "fingerprint": 257114651
                    }
                ],
                "packageFingerprint": 3828674327,
                "gameVersion": [
                    "1.12.2"
                ],
                "installMetadata": null,
                "serverPackFileId": null,
                "hasInstallScript": false
            },
            {
                "id": 2676102,
                "displayName": "ExactSpawn-1.12-1.2.3.17.jar",
                "fileName": "ExactSpawn-1.12-1.2.3.17.jar",
                "fileDate": "2019-02-17T21:53:45.933Z",
                "fileLength": 12495,
                "releaseType": 1,
                "fileStatus": 4,
                "downloadUrl": "https://edge.forgecdn.net/files/2676/102/ExactSpawn-1.12-1.2.3.17.jar",
                "isAlternate": false,
                "alternateFileId": 0,
                "dependencies": [],
                "isAvailable": true,
                "modules": [
                    {
                        "foldername": "META-INF",
                        "fingerprint": 3415676226
                    },
                    {
                        "foldername": "uk",
                        "fingerprint": 2854879410
                    },
                    {
                        "foldername": "pack.mcmeta",
                        "fingerprint": 3273911401
                    },
                    {
                        "foldername": "assets",
                        "fingerprint": 1508881524
                    },
                    {
                        "foldername": "mcmod.info",
                        "fingerprint": 2275652206
                    }
                ],
                "packageFingerprint": 1472556754,
                "gameVersion": [
                    "1.12.2"
                ],
                "installMetadata": null,
                "serverPackFileId": null,
                "hasInstallScript": false
            },
            {
                "id": 2630349,
                "displayName": "ExactSpawn-1.12-1.1.7.4.jar",
                "fileName": "ExactSpawn-1.12-1.1.7.4.jar",
                "fileDate": "2018-10-22T01:19:18.677Z",
                "fileLength": 6671,
                "releaseType": 1,
                "fileStatus": 4,
                "downloadUrl": "https://edge.forgecdn.net/files/2630/349/ExactSpawn-1.12-1.1.7.4.jar",
                "isAlternate": false,
                "alternateFileId": 0,
                "dependencies": [],
                "isAvailable": true,
                "modules": [
                    {
                        "foldername": "META-INF",
                        "fingerprint": 1609325139
                    },
                    {
                        "foldername": "uk",
                        "fingerprint": 3123080949
                    },
                    {
                        "foldername": "pack.mcmeta",
                        "fingerprint": 3273911401
                    },
                    {
                        "foldername": "mcmod.info",
                        "fingerprint": 708272739
                    }
                ],
                "packageFingerprint": 2692958667,
                "gameVersion": [
                    "1.12.2"
                ],
                "installMetadata": null,
                "serverPackFileId": null,
                "hasInstallScript": false
            },
            {
                "id": 2623005,
                "displayName": "ExactSpawn-1.12-1.0.0.jar",
                "fileName": "ExactSpawn-1.12-1.0.0.jar",
                "fileDate": "2018-10-01T16:33:24.683Z",
                "fileLength": 2863,
                "releaseType": 1,
                "fileStatus": 4,
                "downloadUrl": "https://edge.forgecdn.net/files/2623/5/ExactSpawn-1.12-1.0.0.jar",
                "isAlternate": false,
                "alternateFileId": 0,
                "dependencies": [],
                "isAvailable": true,
                "modules": [
                    {
                        "foldername": "META-INF",
                        "fingerprint": 2464251221
                    },
                    {
                        "foldername": "uk",
                        "fingerprint": 1428078323
                    },
                    {
                        "foldername": "mcmod.info",
                        "fingerprint": 2457854792
                    },
                    {
                        "foldername": "pack.mcmeta",
                        "fingerprint": 3273911401
                    }
                ],
                "packageFingerprint": 1492728940,
                "gameVersion": [
                    "1.12.2"
                ],
                "installMetadata": null,
                "serverPackFileId": null,
                "hasInstallScript": false
            },
            {
                "id": 2623495,
                "displayName": "ExactSpawn-1.12-1.1.4.jar",
                "fileName": "ExactSpawn-1.12-1.1.4.jar",
                "fileDate": "2018-10-02T16:29:44.263Z",
                "fileLength": 6490,
                "releaseType": 1,
                "fileStatus": 4,
                "downloadUrl": "https://edge.forgecdn.net/files/2623/495/ExactSpawn-1.12-1.1.4.jar",
                "isAlternate": false,
                "alternateFileId": 0,
                "dependencies": [],
                "isAvailable": true,
                "modules": [
                    {
                        "foldername": "META-INF",
                        "fingerprint": 3197410795
                    },
                    {
                        "foldername": "uk",
                        "fingerprint": 3517247311
                    },
                    {
                        "foldername": "mcmod.info",
                        "fingerprint": 625360759
                    },
                    {
                        "foldername": "pack.mcmeta",
                        "fingerprint": 3273911401
                    }
                ],
                "packageFingerprint": 1433407945,
                "gameVersion": [
                    "1.12.2"
                ],
                "installMetadata": null,
                "serverPackFileId": null,
                "hasInstallScript": false
            },
            {
                "id": 2630762,
                "displayName": "ExactSpawn-1.12-1.2.0.10.jar",
                "fileName": "ExactSpawn-1.12-1.2.0.10.jar",
                "fileDate": "2018-10-23T12:22:37.16Z",
                "fileLength": 12634,
                "releaseType": 1,
                "fileStatus": 4,
                "downloadUrl": "https://edge.forgecdn.net/files/2630/762/ExactSpawn-1.12-1.2.0.10.jar",
                "isAlternate": false,
                "alternateFileId": 0,
                "dependencies": [],
                "isAvailable": true,
                "modules": [
                    {
                        "foldername": "META-INF",
                        "fingerprint": 2045820461
                    },
                    {
                        "foldername": "uk",
                        "fingerprint": 244487422
                    },
                    {
                        "foldername": "pack.mcmeta",
                        "fingerprint": 3273911401
                    },
                    {
                        "foldername": "assets",
                        "fingerprint": 1508881524
                    },
                    {
                        "foldername": "mcmod.info",
                        "fingerprint": 3126622974
                    }
                ],
                "packageFingerprint": 1504889161,
                "gameVersion": [
                    "1.12.2"
                ],
                "installMetadata": null,
                "serverPackFileId": null,
                "hasInstallScript": false
            },
            {
                "id": 2630825,
                "displayName": "ExactSpawn-1.12-1.2.1.14.jar",
                "fileName": "ExactSpawn-1.12-1.2.1.14.jar",
                "fileDate": "2018-10-23T15:47:18.62Z",
                "fileLength": 12536,
                "releaseType": 1,
                "fileStatus": 4,
                "downloadUrl": "https://edge.forgecdn.net/files/2630/825/ExactSpawn-1.12-1.2.1.14.jar",
                "isAlternate": false,
                "alternateFileId": 0,
                "dependencies": [],
                "isAvailable": true,
                "modules": [
                    {
                        "foldername": "META-INF",
                        "fingerprint": 1024134700
                    },
                    {
                        "foldername": "uk",
                        "fingerprint": 1733959869
                    },
                    {
                        "foldername": "pack.mcmeta",
                        "fingerprint": 3273911401
                    },
                    {
                        "foldername": "assets",
                        "fingerprint": 1508881524
                    },
                    {
                        "foldername": "mcmod.info",
                        "fingerprint": 3368898756
                    }
                ],
                "packageFingerprint": 1741362300,
                "gameVersion": [
                    "1.12.2"
                ],
                "installMetadata": null,
                "serverPackFileId": null,
                "hasInstallScript": false
            }
        ]

## Get Featured Addons [/api/v2/addon/featured]

### Get Featured Addons [POST]

+ Request (application/json)

        {
                "GameId": 432,
                "addonIds": [],
                "featuredCount": 6,
                "popularCount": 14,
                "updatedCount": 14
        }

+ Response 200 (application/json)


        Request too long do it yourself

## Get Addons Database Timestamp [/api/v2/addon/timestamp]
### Get Addons Database Timestamp [GET]

+ Response 200 (application/json)

        "2019-06-09T23:34:29.103Z"

## Get Addon By Fingerprint [/api/v2/fingerprint]
### Get Addon By Fingerprint [POST]

+ Request (application/json)

        [
                3028671922
        ]

+ Response 200 (application/json)

        {
            "isCacheBuilt": true,
            "exactMatches": [
                {
                    "id": 310806,
                    "file": {
                        "id": 2657461,
                        "displayName": "Watermark-1.12-1.0.jar",
                        "fileName": "Watermark-1.12-1.0.jar",
                        "fileDate": "2019-01-07T20:37:37.717Z",
                        "fileLength": 9097,
                        "releaseType": 1,
                        "fileStatus": 4,
                        "downloadUrl": "https://edge.forgecdn.net/files/2657/461/Watermark-1.12-1.0.jar",
                        "isAlternate": false,
                        "alternateFileId": 0,
                        "dependencies": [],
                        "isAvailable": true,
                        "modules": [
                            {
                                "foldername": "META-INF",
                                "fingerprint": 1774297949,
                                "type": 3
                            },
                            {
                                "foldername": "uk",
                                "fingerprint": 3536121930,
                                "type": 3
                            },
                            {
                                "foldername": "mcmod.info",
                                "fingerprint": 1697886471,
                                "type": 3
                            },
                            {
                                "foldername": "pack.mcmeta",
                                "fingerprint": 3273911401,
                                "type": 3
                            }
                        ],
                        "packageFingerprint": 3028671922,
                        "gameVersion": [
                            "1.12.2"
                        ],
                        "sortableGameVersion": [
                            {
                                "gameVersionPadded": "0000000001.0000000012.0000000002",
                                "gameVersion": "1.12.2",
                                "gameVersionReleaseDate": "2017-09-18T05:00:00Z",
                                "gameVersionName": "1.12.2"
                            }
                        ],
                        "installMetadata": null,
                        "changelog": null,
                        "hasInstallScript": false,
                        "isCompatibleWithClient": false,
                        "categorySectionPackageType": 6,
                        "restrictProjectFileAccess": 1,
                        "projectStatus": 4,
                        "renderCacheId": 1495256,
                        "fileLegacyMappingId": null,
                        "projectId": 310806,
                        "parentProjectFileId": null,
                        "parentFileLegacyMappingId": null,
                        "fileTypeId": null,
                        "exposeAsAlternative": null,
                        "packageFingerprintId": 285264201,
                        "gameVersionDateReleased": "2017-09-18T05:00:00Z",
                        "gameVersionMappingId": 1729095,
                        "gameVersionId": 6756,
                        "gameId": 432,
                        "isServerPack": false,
                        "serverPackFileId": null
                    },
                    "latestFiles": [
                        {
                            "id": 2657461,
                            "displayName": "Watermark-1.12-1.0.jar",
                            "fileName": "Watermark-1.12-1.0.jar",
                            "fileDate": "2019-01-07T20:37:37.717Z",
                            "fileLength": 9097,
                            "releaseType": 1,
                            "fileStatus": 4,
                            "downloadUrl": "https://edge.forgecdn.net/files/2657/461/Watermark-1.12-1.0.jar",
                            "isAlternate": false,
                            "alternateFileId": 0,
                            "dependencies": [],
                            "isAvailable": true,
                            "modules": [
                                {
                                    "foldername": "META-INF",
                                    "fingerprint": 1774297949,
                                    "type": 3
                                },
                                {
                                    "foldername": "uk",
                                    "fingerprint": 3536121930,
                                    "type": 3
                                },
                                {
                                    "foldername": "mcmod.info",
                                    "fingerprint": 1697886471,
                                    "type": 3
                                },
                                {
                                    "foldername": "pack.mcmeta",
                                    "fingerprint": 3273911401,
                                    "type": 3
                                }
                            ],
                            "packageFingerprint": 3028671922,
                            "gameVersion": [
                                "1.12.2"
                            ],
                            "sortableGameVersion": [
                                {
                                    "gameVersionPadded": "0000000001.0000000012.0000000002",
                                    "gameVersion": "1.12.2",
                                    "gameVersionReleaseDate": "2017-09-18T05:00:00Z",
                                    "gameVersionName": "1.12.2"
                                }
                            ],
                            "installMetadata": null,
                            "changelog": null,
                            "hasInstallScript": false,
                            "isCompatibleWithClient": false,
                            "categorySectionPackageType": 6,
                            "restrictProjectFileAccess": 1,
                            "projectStatus": 4,
                            "renderCacheId": 1495256,
                            "fileLegacyMappingId": null,
                            "projectId": 310806,
                            "parentProjectFileId": null,
                            "parentFileLegacyMappingId": null,
                            "fileTypeId": null,
                            "exposeAsAlternative": null,
                            "packageFingerprintId": 285264201,
                            "gameVersionDateReleased": "2017-09-18T05:00:00Z",
                            "gameVersionMappingId": 1729095,
                            "gameVersionId": 6756,
                            "gameId": 432,
                            "isServerPack": false,
                            "serverPackFileId": null
                        }
                    ]
                }
            ],
            "exactFingerprints": [
                3028671922
            ],
            "partialMatches": [],
            "partialMatchFingerprints": {},
            "installedFingerprints": [
                3028671922
            ],
            "unmatchedFingerprints": []
        }

## Get Minecraft Version Timestamp [/api/v2/minecraft/version/timestamp]
### Get Minecraft Version Timestamp [GET]

+ Response 200 (application/json)

        "2019-06-09T23:34:29.103Z"

## Get Minecraft Version List [/api/v2/minecraft/version]
### Get Minecraft Version List [GET]

+ Response 200 (application/json)

        [
        {
            "id": 60,
            "gameVersionId": 7413,
            "versionString": "1.14.3",
            "jarDownloadUrl": "https://launcher.mojang.com/v1/objects/af100b34ec7ef2b8b9cf7775b544d21d690dddec/client.jar",
            "jsonDownloadUrl": "https://launchermeta.mojang.com/v1/packages/2b9823a8699fb6811acd1f553c5bee009d30f64e/1.14.3.json",
            "approved": false,
            "dateModified": "2019-06-24T15:46:57Z",
            "gameVersionTypeId": 64806,
            "gameVersionStatus": 1,
            "gameVersionTypeStatus": 1
        },
        {
            "id": 52,
            "gameVersionId": 6756,
            "versionString": "1.12.2",
            "jarDownloadUrl": "https://s3.amazonaws.com/Minecraft.Download/versions/1.12.2/1.12.2.jar",
            "jsonDownloadUrl": "https://s3.amazonaws.com/Minecraft.Download/versions/1.12.2/1.12.2.json",
            "approved": false,
            "dateModified": "2018-03-29T17:24:38.393Z",
            "gameVersionTypeId": 628,
            "gameVersionStatus": 1,
            "gameVersionTypeStatus": 1
        },
        {
            "id": 31,
            "gameVersionId": 4482,
            "versionString": "1.0",
            "jarDownloadUrl": "http://s3.amazonaws.com/Minecraft.Download/versions/1.0/1.0.jar",
            "jsonDownloadUrl": "http://s3.amazonaws.com/Minecraft.Download/versions/1.0/1.0.json",
            "approved": false,
            "dateModified": "2018-03-29T17:24:38.393Z",
            "gameVersionTypeId": 16,
            "gameVersionStatus": 3,
            "gameVersionTypeStatus": 1
        }
        ]

## Get Minecraft Version Info [/api/v2/minecraft/version/{VersionString}]
### Get Minecraft Version Info [GET]
+ Parameters
    + VersionString: `1.12.2` (string)

+ Response 200 (application/json)

        {
        "id": 52,
        "gameVersionId": 6756,
        "versionString": "1.12.2",
        "jarDownloadUrl": "https://s3.amazonaws.com/Minecraft.Download/versions/1.12.2/1.12.2.jar",
        "jsonDownloadUrl": "https://s3.amazonaws.com/Minecraft.Download/versions/1.12.2/1.12.2.json",
        "approved": false,
        "dateModified": "2018-03-29T17:24:38.393Z",
        "gameVersionTypeId": 628,
        "gameVersionStatus": 1,
        "gameVersionTypeStatus": 1
        }

## Get Modloader Timestamp [/api/v2/minecraft/modloader/timestamp]
### Get Modloader Timestamp [GET]

+ Response 200 (application/json)

        "2019-06-09T23:34:29.103Z"

## Get Modloader List [/api/v2/minecraft/modloader]
### Get Modloader List [GET]

+ Response 200 (application/json)

        [
        {
            "name": "forge-9.11.1.965",
            "gameVersion": "1.6.4",
            "latest": false,
            "recommended": false,
            "dateModified": "2017-01-01T00:00:00Z"
        },
        {
            "name": "forge-14.23.5.2768",
            "gameVersion": "1.12.2",
            "latest": false,
            "recommended": true,
            "dateModified": "2018-10-04T07:48:00Z"
        },
        {
            "name": "forge-14.23.5.2838",
            "gameVersion": "1.12.2",
            "latest": true,
            "recommended": false,
            "dateModified": "2019-05-13T17:02:00Z"
        },
        {
            "name": "forge-12.17.0.1980",
            "gameVersion": "1.9.4",
            "latest": true,
            "recommended": true,
            "dateModified": "2017-01-01T00:00:00Z"
        }
        ]

## Get Modloader Info [/api/v2/minecraft/modloader/{VersionName}]
### Get Modloader Info [GET]
+ Parameters
    + VersionName: `forge-12.17.0.1980` (string)

+ Response 200 (application/json)

        {
        "id": 2971,
        "gameVersionId": 6166,
        "minecraftGameVersionId": 42,
        "forgeVersion": "12.17.0.1980",
        "name": "forge-12.17.0.1980",
        "type": 1,
        "downloadUrl": "https://modloaders.cursecdn.com/647622546/maven/net/minecraftforge/forge/1.9.4-12.17.0.1980-1.10.0/forge-1.9.4-12.17.0.1980-1.10.0.jar",
        "filename": "forge-1.9.4-12.17.0.1980-1.10.0.jar",
        "installMethod": 1,
        "latest": true,
        "recommended": true,
        "approved": false,
        "dateModified": "2017-01-01T00:00:00Z",
        "mavenVersionString": "net.minecraftforge:forge:1.9.4-12.17.0.1980-1.10.0",
        "versionJson": "{\r\n  \"id\": \"forge-12.17.0.1980\",\r\n  \"time\": \"2016-06-23T04:11:27+0000\",\r\n  \"releaseTime\": \"1960-01-01T00:00:00-0700\",\r\n  \"type\": \"release\",\r\n  \"minecraftArguments\": \"--username ${auth_player_name} --version ${version_name} --gameDir ${game_directory} --assetsDir ${assets_root} --assetIndex ${assets_index_name} --uuid ${auth_uuid} --accessToken ${auth_access_token} --userType ${user_type} --tweakClass net.minecraftforge.fml.common.launcher.FMLTweaker --versionType Forge\",\r\n  \"minimumLauncherVersion\": 0,\r\n  \"inheritsFrom\": \"1.9.4\",\r\n  \"jar\": \"forge-12.17.0.1980\",\r\n  \"libraries\": [\r\n    {\r\n      \"name\": \"net.minecraftforge:forge:1.9.4-12.17.0.1980-1.10.0\",\r\n      \"url\": \"https://modloaders.cursecdn.com/647622546/maven/\"\r\n    },\r\n    {\r\n      \"name\": \"net.minecraft:launchwrapper:1.12\",\r\n      \"serverreq\": true\r\n    },\r\n    {\r\n      \"name\": \"org.ow2.asm:asm-all:5.0.3\",\r\n      \"serverreq\": true\r\n    },\r\n    {\r\n      \"name\": \"jline:jline:2.13\",\r\n      \"url\": \"https://modloaders.cursecdn.com/647622546/maven/\",\r\n      \"serverreq\": true,\r\n      \"clientreq\": false\r\n    },\r\n    {\r\n      \"name\": \"com.typesafe.akka:akka-actor_2.11:2.3.3\",\r\n      \"url\": \"https://modloaders.cursecdn.com/647622546/maven/\",\r\n      \"serverreq\": true,\r\n      \"clientreq\": true\r\n    },\r\n    {\r\n      \"name\": \"com.typesafe:config:1.2.1\",\r\n      \"url\": \"https://modloaders.cursecdn.com/647622546/maven/\",\r\n      \"serverreq\": true,\r\n      \"clientreq\": true\r\n    },\r\n    {\r\n      \"name\": \"org.scala-lang:scala-actors-migration_2.11:1.1.0\",\r\n      \"url\": \"https://modloaders.cursecdn.com/647622546/maven/\",\r\n      \"serverreq\": true,\r\n      \"clientreq\": true\r\n    },\r\n    {\r\n      \"name\": \"org.scala-lang:scala-compiler:2.11.1\",\r\n      \"url\": \"https://modloaders.cursecdn.com/647622546/maven/\",\r\n      \"serverreq\": true,\r\n      \"clientreq\": true\r\n    },\r\n    {\r\n      \"name\": \"org.scala-lang.plugins:scala-continuations-library_2.11:1.0.2\",\r\n      \"url\": \"https://modloaders.cursecdn.com/647622546/maven/\",\r\n      \"serverreq\": true,\r\n      \"clientreq\": true\r\n    },\r\n    {\r\n      \"name\": \"org.scala-lang.plugins:scala-continuations-plugin_2.11.1:1.0.2\",\r\n      \"url\": \"https://modloaders.cursecdn.com/647622546/maven/\",\r\n      \"serverreq\": true,\r\n      \"clientreq\": true\r\n    },\r\n    {\r\n      \"name\": \"org.scala-lang:scala-library:2.11.1\",\r\n      \"url\": \"https://modloaders.cursecdn.com/647622546/maven/\",\r\n      \"serverreq\": true,\r\n      \"clientreq\": true\r\n    },\r\n    {\r\n      \"name\": \"org.scala-lang:scala-parser-combinators_2.11:1.0.1\",\r\n      \"url\": \"https://modloaders.cursecdn.com/647622546/maven/\",\r\n      \"serverreq\": true,\r\n      \"clientreq\": true\r\n    },\r\n    {\r\n      \"name\": \"org.scala-lang:scala-reflect:2.11.1\",\r\n      \"url\": \"https://modloaders.cursecdn.com/647622546/maven/\",\r\n      \"serverreq\": true,\r\n      \"clientreq\": true\r\n    },\r\n    {\r\n      \"name\": \"org.scala-lang:scala-swing_2.11:1.0.1\",\r\n      \"url\": \"https://modloaders.cursecdn.com/647622546/maven/\",\r\n      \"serverreq\": true,\r\n      \"clientreq\": true\r\n    },\r\n    {\r\n      \"name\": \"org.scala-lang:scala-xml_2.11:1.0.2\",\r\n      \"url\": \"https://modloaders.cursecdn.com/647622546/maven/\",\r\n      \"serverreq\": true,\r\n      \"clientreq\": true\r\n    },\r\n    {\r\n      \"name\": \"lzma:lzma:0.0.1\",\r\n      \"serverreq\": true\r\n    },\r\n    {\r\n      \"name\": \"net.sf.jopt-simple:jopt-simple:4.6\",\r\n      \"serverreq\": true\r\n    },\r\n    {\r\n      \"name\": \"java3d:vecmath:1.5.2\",\r\n      \"serverreq\": true,\r\n      \"clientreq\": true\r\n    },\r\n    {\r\n      \"name\": \"net.sf.trove4j:trove4j:3.0.3\",\r\n      \"serverreq\": true,\r\n      \"clientreq\": true\r\n    }\r\n  ],\r\n  \"mainClass\": \"net.minecraft.launchwrapper.Launch\"\r\n}",
        "librariesInstallLocation": "{0}\\libraries\\net\\minecraftforge\\forge\\1.9.4-12.17.0.1980-1.10.0",
        "minecraftVersion": "1.9.4",
        "additionalFilesJson": null,
        "modLoaderGameVersionId": 6166,
        "modLoaderGameVersionTypeId": 3,
        "modLoaderGameVersionStatus": 3,
        "modLoaderGameVersionTypeStatus": 1,
        "mcGameVersionId": 6084,
        "mcGameVersionTypeId": 552,
        "mcGameVersionStatus": 1,
        "mcGameVersionTypeStatus": 1,
        "installProfileJson": null
        }

## Get Category Timestamp [/api/v2/category/timestamp]
### Get Category Timestamp [GET]

+ Response 200 (application/json)

        "2019-06-09T23:34:29.103Z"

## Get Category List [/api/v2/category]
### Get Category List [GET]

+ Response 200 (application/json)

        [
        {
            "id": 4560,
            "name": "Worlds",
            "slug": "worlds",
            "avatarUrl": "https://media.forgecdn.net/avatars/53/343/636123927730726719.png",
            "dateModified": "2016-10-20T17:13:05.457Z",
            "parentGameCategoryId": 4559,
            "rootGameCategoryId": 4559,
            "gameId": 432
        },
        {
            "id": 4561,
            "name": "Resource Packs",
            "slug": "resource-packs",
            "avatarUrl": "https://media.forgecdn.net/avatars/53/344/636123930026778200.png",
            "dateModified": "2016-10-20T00:28:27.25Z",
            "parentGameCategoryId": 4559,
            "rootGameCategoryId": 4559,
            "gameId": 432
        },
        {
            "id": 4780,
            "name": "Fabric",
            "slug": "fabric",
            "avatarUrl": "https://media.forgecdn.net/avatars/182/502/636808438426582276.png",
            "dateModified": "2018-12-19T19:17:22.673Z",
            "parentGameCategoryId": 6,
            "rootGameCategoryId": 6,
            "gameId": 432
        },
        {
            "id": 4471,
            "name": "Modpacks",
            "slug": "modpacks",
            "avatarUrl": "https://media.forgecdn.net/avatars/52/100/636111139251397737.png",
            "dateModified": "2016-10-03T22:52:05.14Z",
            "parentGameCategoryId": null,
            "rootGameCategoryId": null,
            "gameId": 432
        },
        {
            "id": 12,
            "name": "Texture Packs",
            "slug": "texture-packs",
            "avatarUrl": "https://media.forgecdn.net/avatars/52/102/636111139761599118.png",
            "dateModified": "2016-10-03T22:52:56.16Z",
            "parentGameCategoryId": null,
            "rootGameCategoryId": null,
            "gameId": 432
        },
        {
            "id": 6,
            "name": "Mods",
            "slug": "mc-mods",
            "avatarUrl": "https://media.forgecdn.net/avatars/52/101/636111139584399357.png",
            "dateModified": "2018-08-08T19:42:39.42Z",
            "parentGameCategoryId": null,
            "rootGameCategoryId": null,
            "gameId": 432
        }
        ]

## Get Category Info [/api/v2/category/{Categoryid}]
### Get Category Info [GET]
+ Parameters
    + Categoryid: `423` (integer)

+ Response 200 (application/json)

        {
        "id": 423,
        "name": "Map and Information",
        "slug": "map-information",
        "avatarUrl": "https://media.forgecdn.net/avatars/6/38/635351497437388438.png",
        "dateModified": "2014-05-08T17:42:23.74Z",
        "parentGameCategoryId": 6,
        "rootGameCategoryId": 6,
        "gameId": 432
        }

## Get Category Section Info [/api/v2/category/section/{SectionID}]
### Get Category Section Info [GET]
+ Parameters
    + SectionID: `6` (integer)

+ Response 200 (application/json)

        [
        {
            "id": 423,
            "name": "Map and Information",
            "slug": "map-information",
            "avatarUrl": "https://media.forgecdn.net/avatars/6/38/635351497437388438.png",
            "dateModified": "2014-05-08T17:42:23.74Z",
            "parentGameCategoryId": 6,
            "rootGameCategoryId": 6,
            "gameId": 432
        },
        {
            "id": 426,
            "name": "Addons",
            "slug": "mc-addons",
            "avatarUrl": "https://media.forgecdn.net/avatars/5/998/635351477886290676.png",
            "dateModified": "2014-05-08T17:09:48.63Z",
            "parentGameCategoryId": 6,
            "rootGameCategoryId": 6,
            "gameId": 432
        },
        {
            "id": 434,
            "name": "Armor, Tools, and Weapons",
            "slug": "armor-weapons-tools",
            "avatarUrl": "https://media.forgecdn.net/avatars/6/47/635351498790409758.png",
            "dateModified": "2014-05-08T17:44:39.057Z",
            "parentGameCategoryId": 6,
            "rootGameCategoryId": 6,
            "gameId": 432
        }
        ]

## Get Game Timestamp [/api/v2/game/timestamp]
### Get Game Timestamp [GET]

+ Response 200 (application/json)

        "2019-06-09T23:34:29.103Z"

## Get Games List [/api/v2/game{?supportsAddons}]
### Get Games List [GET]
+ Parameters
    + supportsAddons (boolean, optional)
        + Default: true

+ Response 200 (application/json)

        [
        {
            "id": 432,
            "name": "Minecraft",
            "slug": "minecraft",
            "dateModified": "2019-06-26T15:49:27.81Z",
            "gameFiles": [
            {
                "id": 34,
                "gameId": 432,
                "isRequired": true,
                "fileName": "instance.json",
                "fileType": 3,
                "platformType": 4
            }
            ],
            "gameDetectionHints": [
            {
                "id": 9,
                "hintType": 2,
                "hintPath": "%Public%\\Games\\Minecraft",
                "hintKey": null,
                "hintOptions": 0,
                "gameId": 432
            }
            ],
            "fileParsingRules": [],
            "categorySections": [
            {
                "id": 9,
                "gameId": 432,
                "name": "Texture Packs",
                "packageType": 3,
                "path": "resourcepacks",
                "initialInclusionPattern": "([^\\/\\\\]+\\.zip)$",
                "extraIncludePattern": "([^\\/\\\\]+\\.zip)$",
                "gameCategoryId": 12
            },
            {
                "id": 11,
                "gameId": 432,
                "name": "Modpacks",
                "packageType": 5,
                "path": "downloads",
                "initialInclusionPattern": "$^",
                "extraIncludePattern": null,
                "gameCategoryId": 4471
            },
            {
                "id": 8,
                "gameId": 432,
                "name": "Mods",
                "packageType": 6,
                "path": "mods",
                "initialInclusionPattern": ".",
                "extraIncludePattern": null,
                "gameCategoryId": 6
            },
            {
                "id": 10,
                "gameId": 432,
                "name": "Worlds",
                "packageType": 1,
                "path": "saves",
                "initialInclusionPattern": ".",
                "extraIncludePattern": null,
                "gameCategoryId": 17
            }
            ],
            "maxFreeStorage": 0,
            "maxPremiumStorage": 0,
            "maxFileSize": 0,
            "addonSettingsFolderFilter": null,
            "addonSettingsStartingFolder": null,
            "addonSettingsFileFilter": null,
            "addonSettingsFileRemovalFilter": null,
            "supportsAddons": true,
            "supportsPartnerAddons": false,
            "supportedClientConfiguration": 3,
            "supportsNotifications": true,
            "profilerAddonId": 0,
            "twitchGameId": 27471,
            "clientGameSettingsId": 24
        },
        {
            "id": 1,
            "name": "World of Warcraft",
            "slug": "wow",
            "dateModified": "2019-06-26T15:49:20.887Z",
            "gameFiles": [
            {
                "id": 1,
                "gameId": 1,
                "isRequired": false,
                "fileName": "WoW.exe",
                "fileType": 2,
                "platformType": 4
            },
            {
                "id": 2,
                "gameId": 1,
                "isRequired": false,
                "fileName": "WoW-64.exe",
                "fileType": 2,
                "platformType": 3
            },
            {
                "id": 4,
                "gameId": 1,
                "isRequired": false,
                "fileName": "world.MPQ.lock",
                "fileType": 4,
                "platformType": 1
            },
            {
                "id": 143,
                "gameId": 1,
                "isRequired": false,
                "fileName": "World of Warcraft.app",
                "fileType": 2,
                "platformType": 5
            },
            {
                "id": 177,
                "gameId": 1,
                "isRequired": false,
                "fileName": "WowB.exe",
                "fileType": 2,
                "platformType": 4
            },
            {
                "id": 178,
                "gameId": 1,
                "isRequired": false,
                "fileName": "WowB-64.exe",
                "fileType": 2,
                "platformType": 3
            },
            {
                "id": 180,
                "gameId": 1,
                "isRequired": false,
                "fileName": "WowT.exe",
                "fileType": 2,
                "platformType": 4
            },
            {
                "id": 181,
                "gameId": 1,
                "isRequired": false,
                "fileName": "WoWT-64.exe",
                "fileType": 2,
                "platformType": 3
            },
            {
                "id": 184,
                "gameId": 1,
                "isRequired": false,
                "fileName": "World of Warcraft Beta.app",
                "fileType": 2,
                "platformType": 5
            },
            {
                "id": 185,
                "gameId": 1,
                "isRequired": false,
                "fileName": "World of Warcraft Public Test.app",
                "fileType": 2,
                "platformType": 5
            },
            {
                "id": 341,
                "gameId": 1,
                "isRequired": false,
                "fileName": "World of Warcraft Test.app",
                "fileType": 2,
                "platformType": 5
            },
            {
                "id": 342,
                "gameId": 1,
                "isRequired": false,
                "fileName": "World of Warcraft Beta.app",
                "fileType": 2,
                "platformType": 5
            }
            ],
            "gameDetectionHints": [
            {
                "id": 1,
                "hintType": 1,
                "hintPath": "HKEY_LOCAL_MACHINE\\SOFTWARE\\Wow6432Node\\Blizzard Entertainment\\World of Warcraft",
                "hintKey": "InstallPath",
                "hintOptions": 0,
                "gameId": 1
            },
            {
                "id": 2,
                "hintType": 1,
                "hintPath": "HKEY_LOCAL_MACHINE\\SOFTWARE\\Blizzard Entertainment\\World of Warcraft",
                "hintKey": "InstallPath",
                "hintOptions": 0,
                "gameId": 1
            },
            {
                "id": 3,
                "hintType": 1,
                "hintPath": "HKEY_LOCAL_MACHINE\\SOFTWARE\\Classes\\VirtualStore\\MACHINE\\SOFTWARE\\Blizzard Entertainment\\World of Warcraft",
                "hintKey": "InstallPath",
                "hintOptions": 0,
                "gameId": 1
            },
            {
                "id": 4,
                "hintType": 2,
                "hintPath": "%PROGRAMFILES(x86)%\\World of Warcraft",
                "hintKey": null,
                "hintOptions": 0,
                "gameId": 1
            },
            {
                "id": 5,
                "hintType": 2,
                "hintPath": "%PROGRAMFILES%\\World of Warcraft",
                "hintKey": null,
                "hintOptions": 0,
                "gameId": 1
            },
            {
                "id": 6,
                "hintType": 2,
                "hintPath": "%Public%\\Games\\World of Warcraft",
                "hintKey": null,
                "hintOptions": 0,
                "gameId": 1
            },
            {
                "id": 10,
                "hintType": 2,
                "hintPath": "/Applications/World of Warcraft",
                "hintKey": null,
                "hintOptions": 0,
                "gameId": 1
            },
            {
                "id": 22,
                "hintType": 1,
                "hintPath": "HKEY_LOCAL_MACHINE\\SOFTWARE\\Wow6432Node\\Blizzard Entertainment\\World of Warcraft\\PTR",
                "hintKey": "InstallPath",
                "hintOptions": 0,
                "gameId": 1
            },
            {
                "id": 23,
                "hintType": 1,
                "hintPath": "HKEY_LOCAL_MACHINE\\SOFTWARE\\Blizzard Entertainment\\World of Warcraft\\PTR",
                "hintKey": "InstallPath",
                "hintOptions": 0,
                "gameId": 1
            },
            {
                "id": 24,
                "hintType": 1,
                "hintPath": "HKEY_LOCAL_MACHINE\\SOFTWARE\\Classes\\VirtualStore\\MACHINE\\SOFTWARE\\Blizzard Entertainment\\World of Warcraft\\PTR",
                "hintKey": "InstallPath",
                "hintOptions": 0,
                "gameId": 1
            },
            {
                "id": 30,
                "hintType": 2,
                "hintPath": "%PROGRAMFILES(x86)%\\World of Warcraft Beta",
                "hintKey": null,
                "hintOptions": 0,
                "gameId": 1
            },
            {
                "id": 31,
                "hintType": 2,
                "hintPath": "%PROGRAMFILES%\\World of Warcraft Beta",
                "hintKey": null,
                "hintOptions": 0,
                "gameId": 1
            },
            {
                "id": 54,
                "hintType": 2,
                "hintPath": "%PROGRAMFILES(x86)%\\World of Warcraft\\_retail_",
                "hintKey": null,
                "hintOptions": 0,
                "gameId": 1
            },
            {
                "id": 55,
                "hintType": 2,
                "hintPath": "%PROGRAMFILES%\\World of Warcraft\\_retail_",
                "hintKey": null,
                "hintOptions": 0,
                "gameId": 1
            },
            {
                "id": 56,
                "hintType": 2,
                "hintPath": "%Public%\\Games\\World of Warcraft\\_retail_",
                "hintKey": null,
                "hintOptions": 0,
                "gameId": 1
            },
            {
                "id": 57,
                "hintType": 2,
                "hintPath": "%PROGRAMFILES(x86)%\\World of Warcraft\\_ptr_",
                "hintKey": null,
                "hintOptions": 0,
                "gameId": 1
            },
            {
                "id": 58,
                "hintType": 2,
                "hintPath": "%PROGRAMFILES%\\World of Warcraft\\_ptr_",
                "hintKey": null,
                "hintOptions": 0,
                "gameId": 1
            },
            {
                "id": 59,
                "hintType": 2,
                "hintPath": "%Public%\\Games\\World of Warcraft\\_ptr_",
                "hintKey": null,
                "hintOptions": 0,
                "gameId": 1
            },
            {
                "id": 61,
                "hintType": 2,
                "hintPath": "%PROGRAMFILES(x86)%\\World of Warcraft\\_beta_",
                "hintKey": null,
                "hintOptions": 0,
                "gameId": 1
            },
            {
                "id": 62,
                "hintType": 2,
                "hintPath": "%PROGRAMFILES%\\World of Warcraft\\_beta_",
                "hintKey": null,
                "hintOptions": 0,
                "gameId": 1
            },
            {
                "id": 63,
                "hintType": 2,
                "hintPath": "%Public%\\Games\\World of Warcraft\\_beta_",
                "hintKey": null,
                "hintOptions": 0,
                "gameId": 1
            },
            {
                "id": 64,
                "hintType": 2,
                "hintPath": "/Applications/World of Warcraft/_retail_",
                "hintKey": null,
                "hintOptions": 0,
                "gameId": 1
            },
            {
                "id": 65,
                "hintType": 2,
                "hintPath": "/Applications/World of Warcraft/_ptr_",
                "hintKey": null,
                "hintOptions": 0,
                "gameId": 1
            },
            {
                "id": 66,
                "hintType": 2,
                "hintPath": "/Applications/World of Warcraft/_beta_",
                "hintKey": null,
                "hintOptions": 0,
                "gameId": 1
            },
            {
                "id": 67,
                "hintType": 2,
                "hintPath": "/Applications/World of Warcraft Public Test",
                "hintKey": null,
                "hintOptions": 0,
                "gameId": 1
            },
            {
                "id": 68,
                "hintType": 2,
                "hintPath": "/Applications/World of Warcraft Beta",
                "hintKey": null,
                "hintOptions": 0,
                "gameId": 1
            }
            ],
            "fileParsingRules": [
            {
                "commentStripPattern": "(?s)<!--.*?-->",
                "fileExtension": ".xml",
                "inclusionPattern": "(?i)<(?:Include|Script)\\s+file=[\"\"']((?:(?<!\\.\\.).)+)[\"\"']\\s*/>",
                "gameId": 1,
                "id": 0
            },
            {
                "commentStripPattern": "(?m)\\s*#.*$",
                "fileExtension": ".toc",
                "inclusionPattern": "(?mi)^\\s*((?:(?<!\\.\\.).)+\\.(?:xml|lua))\\s*$",
                "gameId": 1,
                "id": 0
            }
            ],
            "categorySections": [
            {
                "id": 1,
                "gameId": 1,
                "name": "Addons",
                "packageType": 1,
                "path": "Interface\\Addons",
                "initialInclusionPattern": "(?i)^([^/]+)[\\\\/]\\1\\.toc$",
                "extraIncludePattern": "(?i)^[^/\\\\]+[/\\\\]Bindings\\.xml$",
                "gameCategoryId": 1
            }
            ],
            "maxFreeStorage": 0,
            "maxPremiumStorage": 0,
            "maxFileSize": 0,
            "addonSettingsFolderFilter": "*",
            "addonSettingsStartingFolder": "WTF/Account",
            "addonSettingsFileFilter": "*.lua;AddOns.txt",
            "addonSettingsFileRemovalFilter": "{Module}.lua",
            "supportsAddons": true,
            "supportsPartnerAddons": false,
            "supportedClientConfiguration": 3,
            "supportsNotifications": true,
            "profilerAddonId": 43270,
            "twitchGameId": 18122,
            "clientGameSettingsId": 1
        }
        ]

## Get Game Info [/api/v2/game/{GameID}]
### Get Game Info [GET]
+ Parameters
    + GameID: `432` (integer)

+ Response 200 (application/json)

        {
        "id": 432,
        "name": "Minecraft",
        "slug": "minecraft",
        "dateModified": "2019-06-26T15:49:27.81Z",
        "gameFiles": [
            {
            "id": 34,
            "gameId": 432,
            "isRequired": true,
            "fileName": "instance.json",
            "fileType": 3,
            "platformType": 4
            }
        ],
        "gameDetectionHints": [
            {
            "id": 9,
            "hintType": 2,
            "hintPath": "%Public%\\Games\\Minecraft",
            "hintKey": null,
            "hintOptions": 0,
            "gameId": 432
            }
        ],
        "fileParsingRules": [],
        "categorySections": [
            {
            "id": 9,
            "gameId": 432,
            "name": "Texture Packs",
            "packageType": 3,
            "path": "resourcepacks",
            "initialInclusionPattern": "([^\\/\\\\]+\\.zip)$",
            "extraIncludePattern": "([^\\/\\\\]+\\.zip)$",
            "gameCategoryId": 12
            },
            {
            "id": 11,
            "gameId": 432,
            "name": "Modpacks",
            "packageType": 5,
            "path": "downloads",
            "initialInclusionPattern": "$^",
            "extraIncludePattern": null,
            "gameCategoryId": 4471
            },
            {
            "id": 8,
            "gameId": 432,
            "name": "Mods",
            "packageType": 6,
            "path": "mods",
            "initialInclusionPattern": ".",
            "extraIncludePattern": null,
            "gameCategoryId": 6
            },
            {
            "id": 10,
            "gameId": 432,
            "name": "Worlds",
            "packageType": 1,
            "path": "saves",
            "initialInclusionPattern": ".",
            "extraIncludePattern": null,
            "gameCategoryId": 17
            }
        ],
        "maxFreeStorage": 0,
        "maxPremiumStorage": 0,
        "maxFileSize": 0,
        "addonSettingsFolderFilter": null,
        "addonSettingsStartingFolder": null,
        "addonSettingsFileFilter": null,
        "addonSettingsFileRemovalFilter": null,
        "supportsAddons": true,
        "supportsPartnerAddons": false,
        "supportedClientConfiguration": 3,
        "supportsNotifications": true,
        "profilerAddonId": 0,
        "twitchGameId": 27471,
        "clientGameSettingsId": 24
        }
