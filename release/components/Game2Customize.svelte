<script lang="ts">
  import { createEventDispatcher } from "svelte";
  import html2canvas from "html2canvas";

  const dispatch = createEventDispatcher();

  /* =========================
   * Props
   * ========================= */
  export let colorDictionary: Record<string, string>;
  export let expressions: string[];

  /* =========================
   * State
   * ========================= */
  let selectedRobot = colorDictionary["#88d0f9"];
  let selectedExpression: string | null = null;

  let showExpressionTab = false;
  let showNextButton = true;
  let showFinishButton = false;

  let tempRobotImage = "";

  /* =========================
   * Actions
   * ========================= */
  async function finish() {
    const el = document.getElementById("color-container")!;
    const canvas = await html2canvas(el, { backgroundColor: null });
    tempRobotImage = canvas.toDataURL("image/png");
    dispatch("finish", tempRobotImage);
  }

  function goToExpressions() {
    showExpressionTab = true;

    // fade out next button
    const nextBtn = document.getElementById("next-btn")!;
    nextBtn.style.opacity = "0";

    // show finish button
    showFinishButton = true;

    requestAnimationFrame(() => {
      const finishButton = document.getElementById("finish-btn")!;
      finishButton.style.opacity = "1";

      nextBtn.style.display = "none";

      setTimeout(() => {
        finishButton.style.pointerEvents = "auto";
      }, 500); // match fade transition
    });

    // adjust grid for expression layout
    const container = document.querySelector(".component-container")!;
    container.style.gridTemplateRows = "repeat(4, 1fr)";
    container.style.gridTemplateColumns = "repeat(2, 1fr)";
  }
</script>


<div class="component-container">
  {#if !showExpressionTab}
    {#each Object.keys(colorDictionary) as color}
      <div
        class="colored-div2"
        style="background-color:{color}"
        on:click={() => (selectedRobot = colorDictionary[color])}
      />
    {/each}
  {:else}
    {#each expressions as expression}
      <div>
        <div
          class="colored-div2 rectangle"
          on:click={() => (selectedExpression = expression)}
          on:touchstart={() => (selectedExpression = expression)}
          style="
            background-image: url({expression});
            background-size: 350%;
            background-position: center 53%;
            background-repeat: no-repeat;
            width: 160px;
            height: 90px;
            border-radius: 10px;
            margin: 8px;
            cursor: pointer;
            box-shadow: 0 3px 8px rgba(0, 0, 0, 0.25);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
          "
        />
      </div>
    {/each}
  {/if}
</div>

{#if showNextButton}
  <button
    id="next-btn"
    class="next-btn fade-btn"
    style="pointer-events: auto;"
    on:click={goToExpressions}
    on:touchstart={goToExpressions}
  >
    Next
  </button>
{/if}

{#if showFinishButton}
  <button
    id="finish-btn"
    class="next-btn fade-btn"
    style="pointer-events: none; opacity: 0;"
    on:click={finish}
    on:touchstart={finish}
  >
    Finish!
  </button>
{/if}

<div class="color-container" id="color-container">
  {#if selectedRobot}
    <div>
      <img
        class="robot-display"
        src={selectedRobot}
        alt="Selected Robot"
      />
    </div>

    {#if selectedExpression}
      <div>
        <img
          class="robot-display"
          src={selectedExpression}
          alt="Selected Expression"
          style="
            width: 100%;
            position: absolute;
            top: 150px;
            left: 0;
          "
        />
      </div>
    {/if}
  {/if}
</div>

<style>

  .fade-btn {
    pointer-events: none;
  }

  .fade-btn[style*="opacity: 1"] {
    pointer-events: auto;
  }

  .robot-display {
    position: absolute;
    top: 150px;
    left: 0;
    width: 100%;
    transition: opacity 1s;
  }

  .component-container {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    grid-template-rows: repeat(4, 1fr);
    gap: 10px;
    align-items: center;
    justify-items: center;
    margin: 30px;
    width: 30%;
    height: calc(98vh - 30px);
    position: absolute;
    left: 0;
    z-index: 20;
  }

  .color-container {
    position: absolute;
    right: 0;
    top: 0;
    width: 70%;
    height: 100%;
  }

  .next-btn {
    position: fixed;
    top: 130px;
    right: 50px;
    background: linear-gradient(135deg, #4a90e2, #357ae8);
    color: white;
    border: none;
    font-size: 20px;
    font-weight: 600;
    padding: 12px 28px;
    cursor: pointer;
    box-shadow: 0 6px 14px rgba(0, 0, 0, 0.25);
    z-index: 1000;
    transition: all 0.25s ease;
  }

  .colored-div2 {
    width: 100px;
    height: 100px;
    border-radius: 8px;
  }
</style>
