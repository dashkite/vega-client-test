import * as Obj from "@dashkite/joy/object"
import { convert } from "@dashkite/bake"
import API from "./api.yaml"
import Authorization from "$lib/engines/lookup/authorization.yaml"
import { PUBLIC_ORIGIN as origin } from "$env/static/public"

cache =
  dispatcher: "normal"


echo = ( object ) ->
  convert from: "utf8", to: "base64", JSON.stringify object

issueRune = ( authorization ) ->
  url = new URL "/echo-rune", origin
  url.searchParams.set "authorization", echo authorization
  response = await fetch url.href
  if response.status != 200
    throw new Error "failed to get echo test rune"
  await response.json()

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

  console.log response
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
    "content-type": [ options.headers[ "content-type" ] ]

  switch options.method
    when "put" then echoResponse "ok", headers, options.body
    else
      echoNoMethod()

echoUnhappyMedia = ( options ) ->
  headers =
    "content-type": [ "application/json" ]

  switch options.method
    when "put" then echoResponse "ok", headers, options.body
    else
      echoNoMethod()

# If a GET request got here, it's a cache miss. Echo PUTs.
echoCacheEmulation = ( options ) ->
  headers =
    "content-type": [ options.headers[ "content-type" ] ]
    "cache-control": [ "max-age=60" ]

  switch options.method
    when "get" then echoResponse "not found", {}, message: "not found"
    when "put" then echoResponse "ok", headers, options.body
    when "delete" then echoResponse "no content", {}
    else
      echoNoMethod()


echoHappyRune = ( options ) ->
  header = options.headers[ "authorization" ]
  if !header?
    return echoResponse "forbidden", {}, message: "missing authorization header"
  if ! /(^rune)|(^credentials)/.test header
    return echoResponse "forbidden", {}, message: "authorization header does not use rune scheme"

  headers =
    "content-type": [ "application/json" ]

  switch options.method
    when "put" then echoResponse "ok", headers, options.body
    else
      echoNoMethod()

echoHappyEmail = ( url, options ) ->
  header = options.headers[ "authorization" ]
  if !header?
    return echoResponse "forbidden", {}, message: "missing authorization header"
  
  if header.startsWith "email"
    location = new URL url
    location.pathname = "/happy-email-wait"
    headers =
      "cache-control": [ "no-cache" ]
      "location": [ location.href ]
      "www-authenticate": [ "rune" ]
    return echo
      description: "unauthorized"
      headers: headers

  if header.startsWith "credentials"
    return echoResponse "ok", {}, options.body


echoHappyEmailWait = ( url, options ) ->
  rune = await issueRune Authorization
  runes = [
    "credentials #{ rune }"
  ]
  headers =
    "content-type": [ "application/json" ]
    "credentials": [ "credentials #{ echo runes }" ]
      
  body = status: "success"
  echoResponse "ok", headers, body



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
    console.log "dispatch", options.method.toUpperCase(), path, options.headers

    switch path
      when "/" then echoDiscovery()
      when "/happy-sky/foo/bar" then echoHappy options
      when "/unhappy-sky/foo/bar" then echoUnhappySky options
      when "/happy-json", "/happy-text", "/happy-binary" then echoHappyMedia options
      when "/unhappy-text", "/unhappy-json" then echoUnhappyMedia options
      when "/cache" then echoCacheEmulation options
      when "/happy-rune" then echoHappyRune options
      when "/happy-email" then echoHappyEmail url, options
      when "/happy-email-wait" then echoHappyEmailWait options
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