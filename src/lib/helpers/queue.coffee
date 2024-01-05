import { Queue } from "@dashkite/joy/iterable"

Queue::push = ( value ) -> @enqueue value
Queue::get = ( value ) -> await @dequeue()
Queue::clear = -> @q = []

queue = Queue.create()

export { queue }