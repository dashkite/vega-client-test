import { PUBLIC_ORIGIN } from "$env/static/public"
import { queue } from "$lib/helpers/queue.coffee"
import { dispatch } from "./echo.coffee"

cache = {}
cache.testDomain = do ->
  ( new URL PUBLIC_ORIGIN ).hostname


test = ( fetch, _url, options ) ->
  url = new URL _url
  options ?= method: "get"
  options.method ?= "get"
  queue.push { type: "request", url, options }
  
  echoValue = await dispatch url, options
  url.searchParams.set "echo", echoValue

  response = await fetch url.href, options
  queue.push { type: "response", response }
  response


isTest = ( _url ) ->
  try
    url = new URL _url
    url.hostname == cache.testDomain && 
      url.pathname != "/echo-rune"
  catch error
    false

Fetch = ( _fetch ) ->
  ( url, options ) ->
    if isTest url
      await test _fetch, url, options
    else
      await _fetch url, options


export { Fetch }