import assert from "@dashkite/assert"
import * as Type from "@dashkite/joy/type"
import { Resource } from "@dashkite/vega-client"
import { queue } from "$lib/helpers/queue.coffee"


prepare = ( Helpers ) ->

  [
    Helpers.test "json", ->
      content = foo: "foo"

      response = await Resource.put
        origin: Helpers.origin
        name: "happy json"
        content: content

      await Helpers.assertDiscover()

      event = await queue.get()
      assert.equal "request", event.type
      assert.equal "put", event.options.method
      assert.equal "/happy-json", event.url.pathname
      
      event = await queue.get()
      assert.equal "response", event.type
      assert.equal 200, event.response.status
      
      assert.deepEqual content, response

    Helpers.test "text", ->
      content = "foo is foo"

      response = await Resource.put
        origin: Helpers.origin
        name: "happy text"
        content: content

      await Helpers.assertDiscover()

      event = await queue.get()
      assert.equal "request", event.type
      assert.equal "put", event.options.method
      assert.equal "/happy-text", event.url.pathname
      
      event = await queue.get()
      assert.equal "response", event.type
      assert.equal 200, event.response.status
      
      assert.deepEqual content, response

    Helpers.test "binary", ->
      content = new ArrayBuffer 8

      response = await Resource.put
        origin: Helpers.origin
        name: "happy binary"
        content: content

      await Helpers.assertDiscover()

      event = await queue.get()
      assert.equal "request", event.type
      assert.equal "put", event.options.method
      assert.equal "/happy-binary", event.url.pathname
      
      event = await queue.get()
      assert.equal "response", event.type
      assert.equal 200, event.response.status
      
      assert Type.isType Blob, response
      assert.equal 2, response.size

  ]

export default prepare