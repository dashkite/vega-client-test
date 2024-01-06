import assert from "@dashkite/assert"
import { Resource } from "@dashkite/vega-client"
import { queue } from "$lib/helpers/queue.coffee"


prepare = ( Helpers ) ->

  [
    Helpers.test "get", ->
      response = await Resource.get
        origin: Helpers.origin
        name: "happy sky"
        bindings:
          alpha: "foo"
          beta: "bar"

      await Helpers.assertDiscover()

      event = await queue.get()
      assert.equal "request", event.type
      assert.equal "get", event.options.method
      assert.equal "/happy-sky/foo/bar", event.url.pathname
      
      event = await queue.get()
      assert.equal "response", event.type
      assert.equal 200, event.response.status
      
      assert.equal "bar", response.bar

    Helpers.test "put", ->
      response = await Resource.put
        origin: Helpers.origin
        name: "happy sky"
        bindings:
          alpha: "foo"
          beta: "bar"
        content:
          foo: "bar"
      
      await Helpers.assertDiscover()

      event = await queue.get()
      assert.equal "request", event.type
      assert.equal "put", event.options.method
      assert.equal "/happy-sky/foo/bar", event.url.pathname
      
      event = await queue.get()
      assert.equal "response", event.type
      assert.equal 200, event.response.status
      
      assert.equal "bar", response.foo

    Helpers.test "delete", ->
      response = await Resource.delete
        origin: Helpers.origin
        name: "happy sky"
        bindings:
          alpha: "foo"
          beta: "bar"
      
      await Helpers.assertDiscover()

      event = await queue.get()
      assert.equal "request", event.type
      assert.equal "delete", event.options.method
      assert.equal "/happy-sky/foo/bar", event.url.pathname
      
      event = await queue.get()
      assert.equal "response", event.type
      assert.equal 204, event.response.status
      
      assert.equal null, response

    Helpers.test "post", ->
      response = await Resource.post
        origin: Helpers.origin
        name: "happy sky"
        bindings:
          alpha: "foo"
          beta: "bar"
        content:
          foo: "baz"
      
      await Helpers.assertDiscover()

      event = await queue.get()
      assert.equal "request", event.type
      assert.equal "post", event.options.method
      assert.equal "/happy-sky/foo/bar", event.url.pathname
      
      event = await queue.get()
      assert.equal "response", event.type
      assert.equal 201, event.response.status
      
      assert.equal "baz", response.foo

  ]

export default prepare