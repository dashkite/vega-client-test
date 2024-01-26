import assert from "@dashkite/assert"
import { HTTP } from "@dashkite/vega-client"
import { queue } from "$lib/helpers/queue.coffee"


prepare = ( Helpers ) ->

  setupCache = ( getContext, putContext ) ->
    # Cache miss on first GET
    try
      await Helpers.Request.run HTTP.get getContext
    catch
    
    await Helpers.assertDiscover()

    event = await queue.get()
    assert.equal "request", event.type
    assert.equal "get", event.options.method
    assert.equal "/cache", event.url.pathname
    
    event = await queue.get()
    assert.equal "response", event.type
    assert.equal 404, event.response.status


    # Write through caching on PUT
    await Helpers.Request.run HTTP.put putContext
    
    await Helpers.assertDiscover()

    event = await queue.get()
    assert.equal "request", event.type
    assert.equal "put", event.options.method
    assert.equal "/cache", event.url.pathname
    
    event = await queue.get()
    assert.equal "response", event.type
    assert.equal 200, event.response.status




  [
    Helpers.test "write through behavior", ->
      getContext = ->
        origin: Helpers.origin
        name: "cache"

      content = value: "alpha"
      putContext = -> { getContext()..., content }

      await setupCache getContext(), putContext()
      
      # Request will draw from cache
      response = await Helpers.Request.run HTTP.get getContext()

      await Helpers.assertDiscover()
      values = queue.values()
      assert.equal 0, values.length
      assert.deepEqual content, response


      # Remove the resource
      response = await Helpers.Request.run HTTP.delete getContext()
    
      await Helpers.assertDiscover()
      
      event = await queue.get()
      assert.equal "request", event.type
      assert.equal "delete", event.options.method
      assert.equal "/cache", event.url.pathname
   
      event = await queue.get()
      assert.equal "response", event.type
      assert.equal 204, event.response.status


      #  Followup GET fails with 404 status
      try
        await Helpers.Request.run HTTP.get getContext()
      catch
      
      await Helpers.assertDiscover()

      event = await queue.get()
      assert.equal "request", event.type
      assert.equal "get", event.options.method
      assert.equal "/cache", event.url.pathname
      
      event = await queue.get()
      assert.equal "response", event.type
      assert.equal 404, event.response.status

  ]

export default prepare