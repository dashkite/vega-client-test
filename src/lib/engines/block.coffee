import lookup from "./lookup/index.coffee";

class Block
  constructor: ({ @id, @name, @tests }) ->

  @make: ({ id, name }) ->
    tests = await lookup id
    new @ { id, name, tests }


export default Block