import assert from "@dashkite/assert"
import { Resource } from "@dashkite/vega-client"
import { queue } from "$lib/helpers/queue.coffee"
import * as RunesClient from "@dashkite/runes-client"
import authorization from "./authorization.yaml"


prepare = ( Helpers ) ->

  authorization.domain = Helpers.domain

  setupRunes = ->
    localStorage.setItem "identity", authorization.identity
    RunesClient.store await Helpers.issueRune authorization


  [
    Helpers.test "Happy Rune Literal", ->
      context = 
        origin: Helpers.origin
        name: "happy rune"
        authorization:
          rune: await Helpers.random encoding: "base64", length: 16
          nonce: await Helpers.nonce()
        content:
          foo: "foo"
      
      response = await Resource.put context

      await Helpers.assertDiscover()
      
      event = await queue.get()
      assert.equal "request", event.type
      assert.equal "put", event.options.method
      assert.equal "/happy-rune", event.url.pathname
      
      event = await queue.get()
      assert.equal "response", event.type
      assert.equal 200, event.response.status

    Helpers.test "Happy Rune Local Storage", ->
      context = 
        origin: Helpers.origin
        name: "happy rune"
        content:
          foo: "foo"
      
      await setupRunes()
      response = await Resource.put context

      await Helpers.assertDiscover()
      
      event = await queue.get()
      assert.equal "request", event.type
      assert.equal "put", event.options.method
      assert.equal "/happy-rune", event.url.pathname
      
      event = await queue.get()
      assert.equal "response", event.type
      assert.equal 200, event.response.status

    Helpers.test "Happy Email", ->
      context = 
        origin: Helpers.origin
        name: "happy email"
        authorization:
          email: authorization.identity
        content:
          foo: "foo"
      
      response = await Resource.put context

      await Helpers.assertDiscover()
      
      event = await queue.get()
      assert.equal "request", event.type
      assert.equal "put", event.options.method
      assert.equal "/happy-email", event.url.pathname
      
      event = await queue.get()
      assert.equal "response", event.type
      assert.equal 401, event.response.status

      event = await queue.get()
      assert.equal "request", event.type
      assert.equal "get", event.options.method
      assert.equal "/happy-email-wait", event.url.pathname
      
      event = await queue.get()
      assert.equal "response", event.type
      assert.equal 200, event.response.status

      event = await queue.get()
      assert.equal "request", event.type
      assert.equal "put", event.options.method
      assert.equal "/happy-email", event.url.pathname
      
      event = await queue.get()
      assert.equal "response", event.type
      assert.equal 200, event.response.status

  ]

export default prepare