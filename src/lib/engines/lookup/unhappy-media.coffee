import assert from "@dashkite/assert"
import * as Type from "@dashkite/joy/type"
import { Resource } from "@dashkite/vega-client"
import { queue } from "$lib/helpers/queue.coffee"


prepare = ( Helpers ) ->

  [
    Helpers.test "mismatch request type", ->
      context =
        origin: Helpers.origin
        name: "unhappy text"
        content: foo: "foo"

      success = null
      try
        await Helpers.Request.run Resource.put context
        success = true
      catch error
        success = false

      await Helpers.assertDiscover()

      if success == true
        throw new Error "request should not have succeeded"

    Helpers.test "mismatch response type", ->
      context =
        origin: Helpers.origin
        name: "unhappy json"
        content: foo: "foo"

      success = null
      try
        await Helpers.Request.run Resource.put context
        success = true
      catch error
        success = false

      await Helpers.assertDiscover()

      event = await queue.get()
      assert.equal "request", event.type
      assert.equal "put", event.options.method
      assert.equal "/unhappy-json", event.url.pathname
      
      event = await queue.get()
      assert.equal "response", event.type
      assert.equal 200, event.response.status

      if success == true
        throw new Error "request should not have succeeded"

  ]

export default prepare