<script>
  import "@shoelace-style/shoelace/dist/components/button/button.js";
  import TestBlock from "$lib/components/TestBlock.svelte";
  import Block from "$lib/engines/block.coffee";
  import { allyEvent } from "$lib/helpers/events.coffee";

  let blocks = [];
  let _blocks = [
    [ "happySky", "Happy Request Response Cycle" ],
    [ "unhappySky", "Unhappy Path Linear Sky Interactions" ],
    [ "happyMedia", "Happy Media Type Inference" ]
  ];
  let state = "ready";
  
  const loadBlocks = async function () {
    for ( const [ id, name ] of _blocks ) {
      blocks.push( await Block.make({ id, name }) );
    }
  };

  const runTests = allyEvent( async function () {
    switch ( state ) {
      case "running":
        return;
      case "complete":
        blocks = [];
        await loadBlocks();
        blocks = blocks;
        state = "ready";
      case "ready":
        break;
    }
    
    for ( let i = 0; i < blocks.length; i++) {
      const block = blocks[ i ];
      console.log( block );
      for ( let j = 0; j < block.tests.length; j++) {
        const test = block.tests[ j ];
        await test.run();
        blocks = blocks; // trigger render.
      }
    }
    
    state = "complete";
  });

</script>

<div class="layout">
  <header>
    <h1>Vega Client Tests</h1>
    <sl-button
      size="medium"
      variant="primary"
      onclick={runTests}
      onkeypress={runTests}>
      Run Tests
    </sl-button>
  </header>
  
  {#await loadBlocks() }
    <sl-spinner style="font-size: 3rem;"></sl-spinner>
  {:then}
    {#each blocks as block (block.id)}
      <TestBlock {block}></TestBlock>
    {/each}
  {/await}
  
</div>

<style>
  .layout {
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    justify-content: flex-start;
    max-width: 40rem;
  }

  sl-button {
    margin-top: 1rem;
  }
</style>

