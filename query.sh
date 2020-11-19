#!/bin/sh

query=$1

PATH="/usr/local/bin:${PATH}"

if [ "$query" = "" ]; then
  exit 0
fi

curl --silent \
     --header "Content-Type: application/json" \
     --request POST \
     --data "{\"name\":\"${query}\",\"languageKey\":\"en\",\"searchType\":\"exact\",\"maxEntries\":15,\"offset\":0}" \
     https://www.zefix.ch/ZefixREST/api/v1/firm/search.json \
| \
jq \
  '{ items:
    [
      .list[]
      | .uid |= ( capture("(?<C>CHE)(?<a>\\d{3})(?<b>\\d{3})(?<c>\\d{3})") | "\(.C)-\(.a).\(.b).\(.c)" )
      | {
        title: "\(.name) (\(.legalSeat), \(.uid))",
        subtitle: .name,
        arg: .name,
        mods: {
          shift: {
            valid: true,
            arg: .uid,
            subtitle: .uid
          },
          alt: {
            valid: true,
            arg: "\(.uid) MWST",
            subtitle: "\(.uid) MWST"
          }
        },
        autocomplete: .name,
        valid: true,
        variables: { name: .name, uid: .uid }
      }
    ]
  }'
