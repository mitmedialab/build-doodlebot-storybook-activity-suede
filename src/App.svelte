<script lang="ts">
  import Activity from "../release/Activity.svelte";
</script>

<center style:width="98vw" style:height="98vh" style:margin="auto">
  <Activity
    context={{
      goToSceneInNextPage: (index) => {
        console.log("Go to scene in next page:", index);
      },
      fromBase: (src: string) => `/${src}`,
    }}
  />
</center>
