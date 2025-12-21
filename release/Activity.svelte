<script lang="ts">
  import { getAssets, type Context } from "./components/GameAssets";
  import Game1Assemble from "./components/Game1Assemble.svelte";
  import Game2Customize from "./components/Game2Customize.svelte";

  export let context: Context;

  let mode: "game1" | "game2" = "game1";
  console.log("App mode:", mode);

  let tempRobotImage = "";

  const {
    colors,
    colorDictionary,
    layers,
    videos,
    sounds,
    expressions,
    srcDictionary,
  } = getAssets(context);

  function enterGame2() {
    const nextModal = document.getElementById("next-modal")!;
    nextModal.style.display = "flex";

    setTimeout(() => {
      nextModal.style.display = "none";
      console.log("Entering game 2...");
      mode = "game2";
    }, 5000);
  }

  function finish(detail: string) {
    tempRobotImage = detail;
    document.getElementById("finish-modal")!.style.display = "flex";
  }
</script>

<div class="full-container">
  {#if mode === "game1"}
    <Game1Assemble
      {colors}
      {layers}
      {videos}
      {srcDictionary}
      {sounds}
      on:complete={() => {
        enterGame2();
      }}
    />
  {:else}
    <Game2Customize
      {colorDictionary}
      {expressions}
      on:finish={(e) => finish(e.detail)}
    />
  {/if}

  <button
    class="exit-btn"
    on:touchstart={() => context.goToSceneInNextPage(0)}
    on:click={() => context.goToSceneInNextPage(0)}
  >
    EXIT
  </button>
</div>

<div class="modal" id="next-modal" style="display: none">
  <div class="modal-content">
    <p><strong style="width: 100%">Nice job!</strong></p>
    <p>Now, pick the color and facial expression of Doodlebot!</p>
  </div>
</div>

<div class="modal" id="finish-modal" style="display: none">
  <div class="modal-content">
    <p><strong style="width: 100%">Looks amazing!</strong></p>

    <div style="padding: 5px">
      <img src={tempRobotImage} style="width: 400px" />
    </div>

    <p>Now, let's....</p>
  </div>
</div>


<style>
  .full-container {
    background-color: #dbdbdb;
    position: relative;
    height: 100vh;
    width: 100vw;
    display: flex;
    overflow: hidden;
  }

  .exit-btn {
    position: fixed;
    top: 50px;
    right: 50px;
    background-color: red;
    color: white;
    border: 5px solid white;
    border-radius: 8px;
    font-size: 36px;
    font-weight: bold;
    padding: 7px 14px;
    text-align: center;
    cursor: pointer;
    outline: none;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
    z-index: 1000;
  }

  .modal {
    position: fixed;
    inset: 0;
    background-color: rgba(0, 0, 0, 0.5);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 1000;
  }

  .modal-content {
    background: white;
    padding: 20px;
    border-radius: 20px;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.4);
    text-align: center;
    font-size: 24px;
    font-family: Arial, Helvetica, sans-serif;
  }

  .modal-content button {
    background-color: #007bff;
    color: white;
    border: none;
    padding: 10px 20px;
    margin: 5px;
    border-radius: 10px;
    font-size: 20px;
  }
</style>
