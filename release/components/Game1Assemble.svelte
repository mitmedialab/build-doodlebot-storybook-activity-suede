<script lang="ts">
  import { onMount, createEventDispatcher } from "svelte";
  import { getAssets } from "./GameAssets";

  const dispatch = createEventDispatcher();

  // -------------------------
  // Props
  // -------------------------

  export let colors: string[];
  export let layers: Record<string, string>;
  export let videos: string[];
  export let srcDictionary: Record<string, string>;
  export let sounds: string[];

  // -------------------------
  // State
  // -------------------------

  let currentVideoIndex = 0;
  let audioElements = sounds.map((s) => new Audio(s));
  let customDragImage: HTMLElement | null = null;
  let interactionLocked = false;

  const checkedDictionary: Record<string, boolean> = {
    board: true,
    cam: true,
    pen: true,
    screen: true,
    wheel1: true,
    wheel2: true,
    speaker: true,
  };

  // -------------------------
  // Helpers
  // -------------------------

  function playSound(index: number) {
    const audio = audioElements[index];
    audio.currentTime = 0;
    audio.play().catch(() => {});
  }

  function createCustomDragImage(target: HTMLElement) {
    customDragImage = target.cloneNode(true) as HTMLElement;
    customDragImage.style.position = "absolute";
    customDragImage.style.pointerEvents = "none";
    customDragImage.style.zIndex = "1000";
    document.body.appendChild(customDragImage);
  }

  // -------------------------
  // Drag logic
  // -------------------------

  function handleTouchStart(event: TouchEvent | MouseEvent) {
    if (interactionLocked) return;

    const target = event.target as HTMLElement;
    if (!target.classList.contains("colored-div")) return;

    event.preventDefault();
    createCustomDragImage(target);

    const moveHandler = (e: TouchEvent | MouseEvent) => {
      const x = "touches" in e ? e.touches[0].clientX : e.clientX;
      const y = "touches" in e ? e.touches[0].clientY : e.clientY;
      if (!customDragImage) return;
      customDragImage.style.left = `${x - 50}px`;
      customDragImage.style.top = `${y - 50}px`;
    };

    const endHandler = () => {
      document.removeEventListener("touchmove", moveHandler);
      document.removeEventListener("mousemove", moveHandler);
      document.removeEventListener("touchend", endHandler);
      document.removeEventListener("mouseup", endHandler);

      if (!customDragImage) return;

      const container = document.getElementById("videoContainer")!;
      const rect = customDragImage.getBoundingClientRect();
      const containerRect = container.getBoundingClientRect();

      const overlap =
        !(rect.right < containerRect.left ||
          rect.left > containerRect.right ||
          rect.bottom < containerRect.top ||
          rect.top > containerRect.bottom);

      if (overlap) {
        const id = parseInt(target.id.replace("color-", ""));
        const video = document.getElementById(`video-${id}`) as HTMLVideoElement;
        if (video) playVideo(video, id);
      }

      customDragImage.remove();
    };

    document.addEventListener("touchmove", moveHandler, { passive: false });
    document.addEventListener("mousemove", moveHandler);
    document.addEventListener("touchend", endHandler);
    document.addEventListener("mouseup", endHandler);
  }

  // -------------------------
  // Video logic
  // -------------------------

  function playVideo(video: HTMLVideoElement, id: number) {
    interactionLocked = true;
    currentVideoIndex = id;

    const layers = document.querySelectorAll(".image-layer");
    const parts = document.querySelectorAll(".colored-div");

    video.addEventListener(
      "play",
      () => {
        parts.forEach((p) => p.classList.add("grayscale"));
        console.log("layers", layers)
        layers.forEach((l) => l.classList.add("hide"));
        playSound(id);
      },
      { once: true }
    );

    video.addEventListener(
      "ended",
      () => {
        parts.forEach((p) => p.classList.remove("grayscale"));
        layers.forEach((l) => l.classList.remove("hide"));
        interactionLocked = false;

        document.getElementById(`checkmark-${id}`)!.style.opacity = "1";

        const path = "./" + new URL(video.src).pathname.slice(1);
        const checkedId = srcDictionary[path];

        if (checkedId === "wheel") {
          checkedDictionary.wheel1 = true;
          checkedDictionary.wheel2 = true;
        } else {
          checkedDictionary[checkedId] = true;
        }

        console.log("Checked dictionary:", checkedDictionary);
        if (Object.values(checkedDictionary).every(Boolean) && id !== 7) {
          const endVideo = document.getElementById("video-7") as HTMLVideoElement;
          currentVideoIndex = 7;
          requestAnimationFrame(() => playEndVideo(endVideo));
        }
      },
      { once: true }
    );

    video.play();
  }

  function playEndVideo(video: HTMLVideoElement) {
    interactionLocked = true;

    const layers = document.querySelectorAll(".image-layer");
    const parts = document.querySelectorAll(".colored-div");

    video.addEventListener(
      "play",
      () => {
        parts.forEach((p) => p.classList.add("grayscale"));
        layers.forEach((l) => l.classList.add("hide"));
      },
      { once: true }
    );

    video.addEventListener(
      "ended",
      () => {
        interactionLocked = false;
        dispatch("complete");
      },
      { once: true }
    );

    video.play();
  }

  // -------------------------
  // Lifecycle
  // -------------------------

  onMount(() => {
    console.log("Game1Assemble mounted");
    document.addEventListener("touchstart", handleTouchStart, { passive: false });
    document.addEventListener("mousedown", handleTouchStart);
  });
</script>

<div class="video-container" id="videoContainer">
  {#each videos as src, index}
    <video
      src={src}
      id={"video-" + index}
      class:visible={index === currentVideoIndex}
      muted
    />
  {/each}

  {#each Object.entries(layers) as [id, imageSrc], index}
        <img
        src={imageSrc}
        alt={id}
        class="image-layer game1"
        class:hidden-layer={!checkedDictionary[id]}
        style="position: absolute; z-index: 10; width: 100%"
        id={"layer-" + id}
        />
    {/each}
</div>

<div class="component-container">
  {#each colors as color, index}
    <div>
      <img id={"color-" + index} class="colored-div" src={color} />
      <span id={"checkmark-" + index} style="opacity:0" class="checkmark">✔️</span>
    </div>
  {/each}
</div>

<style>
  :global(.hide) {
    opacity: 0;
  }
  video {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      object-fit: cover; /* Ensures the video covers the container */
      opacity: 0; /* Start with videos hidden */
      transition: opacity 1s; /* Smooth transition for visibility change */
      z-index: 1;
  }

  .video-container video.visible {
      opacity: 1; /* Make the current video visible */
      z-index: 1; /* Ensure it's on top */
  }

  .checkmark {
      position: relative;
      top: 5px; /* Position as needed */
      right: -5px; /* Position as needed */
      font-size: 18px; /* Adjust size as needed */
      color: green; /* Adjust color as needed */
      background-color: green;
      padding: 5px;
      border-radius: 5px;
  }

  .colored-div {
      width: 100px; /* Adjust as needed */
      height: 100px; /* Adjust as needed */
      border-radius: 8px; /* Optional: rounded corners */
  }
  .colored-div2 {
      width: 100px; /* Adjust as needed */
      height: 100px; /* Adjust as needed */
      border-radius: 8px; /* Optional: rounded corners */
  }

  .component-container {
      display: grid;
      grid-template-columns: repeat(2, 1fr); /* 2 columns */
      grid-template-rows: repeat(4, 1fr); /* 4 rows to cover the height */
      gap: 10px; /* Spacing between items */
      align-items: center; /* Center items vertically in each cell */
      justify-items: center; /* Center items horizontally in each cell */
      margin: 30px;
      height: 50%; /* Adjust as needed */
      width: 30%;
      height: calc(98vh - 30px);
      position: absolute;
      left: 0px;
      z-index: 20;
  }
  .video-container {
      display: flex;
      justify-content: center;
      background-color: #dbdbdb;
      align-items: center;
      height: calc(100% - 2rem);
      position: absolute;
      right: -250px;
      width: 100%;
      bottom:-2rem;
      overflow: hidden; /* Ensure content does not overflow */
  }
  .image-layer {
    transition: opacity 0.5s ease, transform 0.5s ease;
  }

  :global(.grayscale) {
      filter: grayscale(100%);
  }

  .hidden-layer {
    opacity: 0;
}

</style>