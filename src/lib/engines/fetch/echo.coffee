import * as Obj from "@dashkite/joy/object"
import { convert } from "@dashkite/bake"
import API from "./api.yaml"

cache =
  dispatcher: "normal"


echo = ( object ) ->
  convert from: "utf8", to: "safe-base64", JSON.stringify object

echoDiscovery = ->
  cache.discovery ?= echo
    description: "ok"
    content: API
    headers:
      "content-type": [ "application/json" ]

echoResponse = ( description, _headers, content ) ->
  defaults =
    "cache-control": [ "no-cache" ]

  headers = Obj.merge defaults, _headers

  response = { description, content, headers }
  if description != "no content"
    response.headers[ "content-type" ] ?= [ "application/json" ]

  echo response

echoNoMethod = ->
  echo
    description: "method not allowed"

echoHappy = ( options ) ->
  switch options.method
    when "get" then echoResponse "ok", {}, bar: "bar"
    when "put" then echoResponse "ok", {}, options.body ? {}
    when "post" then echoResponse "created", {}, options.body ? {}
    when "delete" then echoResponse "no content", {}
    else
      echoNoMethod()
      

echoUnhappySky = ( options ) ->
  switch options.method
    when "post" then echoResponse "created", {}, bar: "bar"
    else
      echoNoMethod()

echoHappyMedia = ( options ) ->
  headers =
    "content-type": options.headers[ "accept" ][ 0 ]

  switch options.method
    when "put" then echoResponse "ok", headers, options.body
    else
      echoNoMethod()


dispatchers = 
  "bad discovery": ( url, options ) ->
    path = url.pathname
    console.log "dispatch", options.method.toUpperCase(), path

    switch path
      when "/"
        echoResponse "bad request", {}, 
          message: "purposefully bad discovery response"
      else
        throw new Error "no matching dispatch for path #{ path }"

  normal: ( url, options ) ->
    path = url.pathname
    console.log "dispatch", options.method.toUpperCase(), path

    switch path
      when "/" then echoDiscovery()
      when "/happy-sky/foo/bar" then echoHappy options
      when "/unhappy-sky/foo/bar" then echoUnhappySky options
      when "/happy-media" then echoHappyMedia url, options
      else
        throw new Error "no matching dispatch for path #{ path }"

dispatch = ( url, options ) ->
  dispatchers[ cache.dispatcher ] url, options

setDispatcher = ( name ) ->
  cache.dispatcher = name


export {
  echo
  dispatch
  setDispatcher
}