<script>
  import "@shoelace-style/shoelace/dist/components/alert/alert.js";
  import "@shoelace-style/shoelace/dist/components/icon/icon.js";
  export let test;

  let icon, variant, error;

  const icons = {
    "start": "slash-square",
    "success": "check2-circle",
    "failure": "exclamation-octagon",
    "warning": "exclamation-triangle"
  };

  const variants = {
    "start": "neutral",
    "success": "success",
    "failure": "danger",
    "warning": "warning"
  };

  const setState = function ( test ) {
    icon = icons[ test.state ];
    variant = variants[ test.state ];
    error = test.error;
  };

  $: setState( test )
</script>

<sl-alert open variant={ variant }>
  <sl-icon slot="icon" src="/icons/{ icon }.svg"></sl-icon>
  <h3>{test.name}</h3>
  {#if error}
    <section>
      <code>{error}</code>
    </section>
  {/if}
</sl-alert>

<style>
  sl-alert {
    width: 100%;
  }
</style>