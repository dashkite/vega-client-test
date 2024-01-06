import assert from "@dashkite/assert"
import { Resource } from "@dashkite/vega-client"
import { queue } from "$lib/helpers/queue.coffee"


prepare = ( Helpers ) ->

  [
    Helpers.test "get", ->
      response = await Resource.put
        origin: Helpers.origin
        name: "happy media"
        headers:
          accept: "application/json"
        content:
          foo: "foo"

      await Helpers.assertDiscover()

      event = await queue.get()
      console.log event.options
      assert.equal "request", event.type
      assert.equal "put", event.options.method
      assert.equal "/happy-media", event.url.pathname
      
      event = await queue.get()
      console.log event.response
      assert.equal "response", event.type
      assert.equal 200, event.response.status
      
      assert.equal "bar", response.bar

  ]

export default prepare