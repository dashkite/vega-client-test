import assert from "@dashkite/assert"
import Credentials from "@dashkite/sierra"
import { queue } from "$lib/helpers/queue.coffee"
import * as RunesClient from "@dashkite/runes-client"
import authorization from "./authorization.yaml"


prepare = ( Helpers ) ->

  authorization.domain = Helpers.domain


  [
    Helpers.test "Build Credentials", ->
      Helpers.clearRunes authorization.identity
      RunesClient.store await Helpers.issueRune authorization
      
      iterator = Credentials.build
        type: "rune"
        resource:
          domain: Helpers.domain
          name: "happy rune"
          method: "put"

      for current from iterator
        if current.failure
          console.log current
          throw current.error
      
      result = current.context.credentials
      console.log result
      assert result?
      assert result.startsWith "credentials "


  ]

export default prepare