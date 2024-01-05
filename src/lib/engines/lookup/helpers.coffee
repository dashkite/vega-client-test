import { confidential } from "panda-confidential"
import { PUBLIC_ORIGIN as origin } from "$env/static/public"
import { queue } from "$lib/helpers/queue.coffee"

Confidential = confidential()


random = ( options = {} ) ->
  { length = 16, encoding = "base36" } = options
  Confidential.convert from: "bytes", to: encoding,
    await Confidential.randomBytes length

now = -> ( new Date ).toISOString()


class Test
  constructor: ({ @name, @test }) ->
    @state = "start"
  
  @make: ( name, test ) -> new @ { name, test }

  run: ->
    if !@test?
      @state = "warning"
      return

    try
      await @test()
      @state = "success"
    catch error
      console.error @name, error
      @state = "failure"
    
    queue.clear()


test = ( name, _test ) -> Test.make name, _test


export {
  random
  now
  origin
  test
}