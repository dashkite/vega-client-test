import assert from "@dashkite/assert"
import { Resource } from "@dashkite/vega-client"
import { queue } from "$lib/helpers/queue.coffee"
import * as RunesClient from "@dashkite/runes-client"
import authorization from "./authorization.yaml"


prepare = ( Helpers ) ->

  authorization.domain = Helpers.domain


  [
    Helpers.test "Rune Literal", ->
      context = 
        origin: Helpers.origin
        name: "unhappy rune"
        authorization:
          rune: await Helpers.random encoding: "base64", length: 16
          nonce: await Helpers.nonce()
        content:
          foo: "foo"
      
      Helpers.clearRunes authorization.identity
      success = null
      try
        await Resource.put context
        success = true
      catch error
        success = false

      await Helpers.assertDiscover()
      
      event = await queue.get()
      assert.equal "request", event.type
      assert.equal "put", event.options.method
      assert.equal "/unhappy-rune", event.url.pathname
      
      event = await queue.get()
      assert.equal "response", event.type
      assert.equal 403, event.response.status

      if success == true
        throw new Error "request should not have succeeded"


    Helpers.test "Rune From localStorage", ->
      context = 
        origin: Helpers.origin
        name: "unhappy rune"
        content:
          foo: "foo"
      
      Helpers.clearRunes authorization.identity
      success = null
      try
        await Resource.put context
        success = true
      catch error
        success = false

      await Helpers.assertDiscover()

      values = queue.values()
      assert.equal 0, values.length
      
      if success == true
        throw new Error "request should not have succeeded"

    Helpers.test "Rune From Email Flow", ->
      context = 
        origin: Helpers.origin
        name: "unhappy email"
        authorization:
          email: authorization.identity
        content:
          foo: "foo"
      
      Helpers.clearRunes authorization.identity
      success = null
      try
        await Resource.put context
        success = true
      catch error
        success = false

      await Helpers.assertDiscover()

      event = await queue.get()
      assert.equal "request", event.type
      assert.equal "put", event.options.method
      assert.equal "/unhappy-email", event.url.pathname
      
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

      values = queue.values()
      assert.equal 0, values.length
      
      if success == true
        throw new Error "request should not have succeeded"

  ]

export default prepare