import assert from "@dashkite/assert"
import { Resource } from "@dashkite/vega-client"

prepare = ( Helpers ) ->

  [
    Helpers.test "get", ->
      response = await Resource.get
        origin: Helpers.origin
        echo:
          discover: Helpers.echoDiscovery()
          resource: Helpers.echoJSON "ok", $echo: true
        name: "simple"
        bindings:
          alpha: "foo"
          beta: "bar"
      
      assert.equal "/foo/bar", response.$echo.path
  ]

export default prepare