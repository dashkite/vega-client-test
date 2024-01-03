<script>
  import "@shoelace-style/shoelace/dist/components/spinner/spinner.js";
  import TestPanel from "$lib/components/TestPanel.svelte";
  export let block;
</script>

<section>
  <header>
    <h2>{ block.name }</h2>
  </header>

  {#each block.tests as test }
    <TestPanel { test }></TestPanel>
  {/each}
</section>

<style>
  section {
    width: 100%;
    margin-top: 2rem;
  }
</style>