<script>
  import "@shoelace-style/shoelace/dist/themes/light.css";
  import "@shoelace-style/shoelace/dist/themes/dark.css";
  import "$lib/styles/reset.css";
  import { onMount } from "svelte";
  import { Fetch } from "$lib/engines/fetch/index.coffee";

  let main;
  window.fetch = Fetch( window.fetch );

  onMount(() => {
    if ( window.matchMedia("(prefers-color-scheme: light)").matches ) {
      main.classList.toggle( "sl-theme-light" );
      main.classList.toggle( "sl-theme-dark" );
    }
  });
</script>

<main bind:this={main} class="sl-theme-dark">
  <slot></slot>
</main>


<style>
</style>