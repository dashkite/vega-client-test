import { convert } from "@dashkite/bake"
import API from "./api.yaml"

cache = {}


echo = ( object ) ->
  convert from: "utf8", to: "safe-base64", JSON.stringify object

echoDiscovery = ->
  cache.discovery ?= echo
    description: "ok"
    content: API
    headers:
      "content-type": [ "application/json" ]

echoJSON = ( description, headers, content ) ->
  response = { description, content, headers: {} }
  if description != "no content"
    response.headers[ "content-type" ] = [ "application/json" ]

  echo response

echoBasic = ( options ) ->
  if options.method == "get"
    echoJSON "ok", {}, bar: "bar"
  else if options.method == "put"
    echoJSON "ok", {}, options.body ? {}
  else if options.method == "post"
    echoJSON "created", {}, options.body ? {}
  else if options.method == "delete"
    echoJSON "no content", {}


dispatch = ( url, options ) ->
  path = url.pathname
  console.log "dispatch", options.method.toUpperCase(), path

  switch path
    when "/" then echoDiscovery()
    when "/foo/bar" then echoBasic options
    else
      throw new Error "no matching dispatch for path #{ path }"


export {
  echo
  dispatch
}