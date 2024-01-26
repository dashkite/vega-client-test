import assert from "@dashkite/assert"
import { HTTP } from "@dashkite/vega-client"
import { queue } from "$lib/helpers/queue.coffee"


prepare = ( Helpers ) ->

  [
    Helpers.test "discovery failure", ->
      Helpers.setDispatcher "bad discovery"
      
      context =
        origin: Helpers.origin
        name: "unhappy sky"
        bindings:
          alpha: "foo"
          beta: "bar"

      success = null
      try
        await Helpers.Request.run HTTP.get context
        success = true
      catch error
        success = false

      event = await queue.get()
      assert.equal "request", event.type
      assert.equal "get", event.options.method
      assert.equal "/", event.url.pathname

      event = await queue.get()
      assert.equal "response", event.type
      assert.equal 400, event.response.status

      if success == true
        throw new Error "discovery request should not have succeeded"


    Helpers.test "resource match failure", ->
      context =
        origin: Helpers.origin
        name: "doesn't exist"
        bindings:
          alpha: "foo"
          beta: "bar"

      success = null
      try
        await Helpers.Request.run HTTP.get context
        success = true
      catch error
        success = false

      await Helpers.assertDiscover()

      if success == true
        throw new Error "request should not have succeeded"


    Helpers.test "method match failure", ->
      context =
        origin: Helpers.origin
        name: "unhappy sky"
        bindings:
          alpha: "foo"
          beta: "bar"

      success = null
      try
        await Helpers.Request.run HTTP.get context
        success = true
      catch error
        success = false

      await Helpers.assertDiscover()

      if success == true
        throw new Error "request should not have succeeded"


    Helpers.test "response status failure", ->
      context =
        origin: Helpers.origin
        name: "unhappy sky"
        bindings:
          alpha: "foo"
          beta: "bar"

      success = null
      try
        await Helpers.Request.run HTTP.post context
        success = true
      catch error
        success = false
      
      await Helpers.assertDiscover()
      event = await queue.get()
      assert.equal "request", event.type
      assert.equal "post", event.options.method
      assert.equal "/unhappy-sky/foo/bar", event.url.pathname

      event = await queue.get()
      assert.equal "response", event.type
      assert.equal 201, event.response.status


  ]

export default prepare