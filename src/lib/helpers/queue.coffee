import { Queue } from "@dashkite/joy/iterable"

_queue = Queue.create()

queue =
  push: ( value ) -> _queue.enqueue value
  get: -> await _queue.dequeue()
  clear: ->
    _queue = Queue.create()
  values: ->
    [ _queue.p..., _queue.q... ]

export { queue }