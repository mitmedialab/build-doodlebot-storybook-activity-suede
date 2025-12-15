<script lang="ts" context="module">
  type Context = {
    goToSceneInNextPage: (sceneIndex: number) => void;
    fromBase: (src: string) => string;
  };

  const isTouchEvent = (event: TouchEvent | MouseEvent): event is TouchEvent =>
    event.type === "touchstart" ||
    event.type === "touchmove" ||
    event.type === "touchend";

  const assetsBasePath = "build-a-doodlebot";

  const getAssets = ({ fromBase }: Pick<Context, "fromBase">) => {
    const image = (id: string) => fromBase(`${assetsBasePath}/images/${id}`);
    const video = (id: string) => fromBase(`${assetsBasePath}/videos/${id}`);
    const sound = (id: string) => fromBase(`${assetsBasePath}/sounds/${id}`);

    const colors = [
      "board.png",
      "cam2.png",
      "mic2.png",
      "pen.png",
      "screen2.png",
      "wheel.png",
      "speak4.png",
    ].map(image);

    const colorDictionary = {
      "#88d0f9": image("colors/DB1_v09-Blue.png"),
      "#f9c37f": image("colors/DB1_v09-Gold.png"),
      "#f984b0": image("colors/DB1_v09-Pink.png"),
      "#a182ff": image("colors/DB1_v09-Grape.png"),
      "#cf98e5": image("colors/DB1_v09-Lavender.png"),
      "#92ed8f": image("colors/DB1_v09-Lime.png"),
    };

    const expressions = [
      "expressions/DB1_v09-Front-Angry.png",
      "expressions/DB1_v09-Front-Annoyed.png",
      "expressions/DB1_v09-Front-Baseline.png",
      "expressions/DB1_v09-Front-Confused.png",
      "expressions/DB1_v09-Front-Disgust.png",
      "expressions/DB1_v09-Front-Love.png",
      "expressions/DB1_v09-Front-Sad3.png",
      "expressions/DB1_v09-Front-Surprise.png",
    ].map(image);

    const game2Colors = [
      "#88d0f9",
      "#f9c37f",
      "#f984b0",
      "#a182ff",
      "#cf98e5",
      "#92ed8f",
    ];

    const layers = {
      wheel1: image("layers/BackWheelLayer.png"),
      cam: image("layers/CameraLayer.png"),
      wheel2: image("layers/FrontWheelLayer.png"),
      board: image("layers/MainBoardLayer.png"),
      microphone: image("layers/MicrophoneLayer.png"),
      pen: image("layers/PenLayer.png"),
      screen: image("layers/ScreenLayer.png"),
      speaker: image("layers/SpeakerLayer.png"),
    };

    const videos = [
      "DB_amazing_v02_board.mp4",
      "DB_amazing_v02_cam.mp4",
      "DB_amazing_v02_mic.mp4",
      "DB_amazing_v02_pen.mp4",
      "DB_amazing_v02_screen.mp4",
      "DB_amazing_v02_wheels.mp4",
      "DB_amazing_v02_speaker.mp4",
      "CompletedDoodleBotDance.mp4",
    ].map(video);

    const srcDictionary = {
      [video("DB_amazing_v02_board.mp4")]: "board",
      [video("DB_amazing_v02_cam.mp4")]: "cam",
      [video("DB_amazing_v02_mic.mp4")]: "microphone",
      [video("DB_amazing_v02_pen.mp4")]: "pen",
      [video("DB_amazing_v02_screen.mp4")]: "screen",
      [video("DB_amazing_v02_wheels.mp4")]: "wheel",
      [video("DB_amazing_v02_speaker.mp4")]: "speaker",
    };

    const sounds = [
      "board.mp3",
      "cam.mp3",
      "mic.mp3",
      "pen.mp3",
      "screen.mp3",
      "wheels.mp3",
      "speaker.mp3",
    ].map(sound);

    return {
      colors,
      colorDictionary,
      layers,
      videos,
      sounds,
      expressions,
      game2Colors,
      srcDictionary,
    };
  };
</script>

<script lang="ts">
  import { onMount } from "svelte";

  export let context: Context;
  import html2canvas from "html2canvas";

  const {
    colors,
    colorDictionary,
    layers,
    videos,
    sounds,
    expressions,
    game2Colors,
    srcDictionary,
  } = getAssets(context);

  let selectedRobot = colorDictionary["#88d0f9"];
  let selectedExpression: string | undefined = undefined;
  let fullContainer: HTMLElement;

  const initialCheckedState = false;

  const checkedDictionary = {
    board: initialCheckedState,
    cam: initialCheckedState,
    pen: initialCheckedState,
    screen: initialCheckedState,
    wheel1: initialCheckedState,
    wheel2: initialCheckedState,
    speaker: initialCheckedState,
  };

  const playCompletdVideoDelayMs = 2000;
  const showNextModalMessageDurationMs = 5000;

  let mode = "game1";

  let showExpressionTab = false;

  let overlayCheckedComponents = false;

  let audioElements = sounds.map((sound) => new Audio(sound));

  function playSound(index: number) {
    // Play the audio corresponding to the video index
    audioElements[index].currentTime = 0; // Reset to start
    audioElements[index].play().catch((error) => {
      console.error("Error attempting to play sound:", error);
    });
    console.log("Playing sound for video index:", index);
  }

  let customDragImage;
  function createCustomDragImage(target: HTMLElement) {
    const rect = target.getBoundingClientRect();
    customDragImage = target.cloneNode(true);
    customDragImage.style.position = "absolute";
    customDragImage.style.left = rect.left + "px";
    customDragImage.style.top = rect.top + "px";
    customDragImage.id = "custom-" + target.id;
    customDragImage.style.pointerEvents = "none"; // Avoid interference with mouse/touch events
    customDragImage.style.zIndex = "1000";
    fullContainer.appendChild(customDragImage);
    return customDragImage;
  }

  function handleTouchStart(event: TouchEvent | MouseEvent) {
    const target = event.target as HTMLElement;
    event.preventDefault();
    if (target.classList.contains("colored-div") && mode == "game1") {
      console.log("CREATING CUSTOM DRAG IMAGE");
      createCustomDragImage(target);

      document.addEventListener("touchmove", handleTouchMove, {
        passive: false,
      });
      document.addEventListener("touchend", handleTouchEnd, {
        passive: false,
      });
      document.addEventListener("mousemove", handleTouchMove, {
        passive: false,
      });
      document.addEventListener("mouseup", handleTouchEnd, {
        passive: false,
      });

      function handleTouchMove(event: TouchEvent | MouseEvent) {
        event.preventDefault();
        if (isTouchEvent(event)) {
          const touch = event.touches[0];
          const offsetX = customDragImage.offsetWidth / 2;
          const offsetY = customDragImage.offsetHeight / 2;

          customDragImage.style.left = `${touch.clientX - offsetX}px`;
          customDragImage.style.top = `${touch.clientY - offsetY}px`;
        } else {
          const offsetX = customDragImage.offsetWidth / 2;
          const offsetY = customDragImage.offsetHeight / 2;

          customDragImage.style.left = `${event.clientX - offsetX}px`;
          customDragImage.style.top = `${event.clientY - offsetY}px`;
        }
      }

      function handleTouchEnd(event: TouchEvent | MouseEvent) {
        document.removeEventListener("touchmove", handleTouchMove);
        document.removeEventListener("touchend", handleTouchEnd);
        document.removeEventListener("mousemove", handleTouchMove);
        document.removeEventListener("mouseup", handleTouchEnd);

        let id;

        function isElementOnTopOfContainer(element, container) {
          const elementRect = element.getBoundingClientRect();
          const containerRect = container.getBoundingClientRect();
          const isOverlapping = !(
            elementRect.right < containerRect.left + 300 ||
            elementRect.left > containerRect.right ||
            elementRect.bottom < containerRect.top ||
            elementRect.top > containerRect.bottom
          );

          return isOverlapping;
        }

        const container = document.getElementById("videoContainer");
        if (isElementOnTopOfContainer(customDragImage, container)) {
          if (customDragImage) {
            id = customDragImage.id;
            id = id.replace("custom-color-", "");
            customDragImage.remove();
          } else {
            id = "1";
          }
          currentVideoIndex = parseInt(id);
          let videoIndex = "video-" + id;
          let videoElement = document.getElementById(videoIndex);

          if (videoElement instanceof HTMLVideoElement) {
            const coloredDivs = document.querySelectorAll(".colored-div");

            function playListener1() {
              overlayCheckedComponents = false;
              coloredDivs.forEach((div) => {
                div.classList.add("grayscale");
              });

              setTimeout(() => {
                playSound(id);
              }, 1000);
              document.removeEventListener("touchstart", handleTouchStart);
              document.removeEventListener("mousedown", handleTouchStart);
            }
            videoElement.addEventListener("play", playListener1);

            // skip to 1.25 second
            videoElement.currentTime = 1.25;

            videoElement.play().catch((error) => {
              console.error("Error attempting to play video:", error);
            });
            videoElement.addEventListener("ended", () => {
              coloredDivs.forEach((div) => {
                div.classList.remove("grayscale");
              });

              overlayCheckedComponents = true;

              document.addEventListener("touchstart", handleTouchStart, {
                passive: false,
              });
              document.addEventListener("mousedown", handleTouchStart, {
                passive: false,
              });
              videoElement.removeEventListener("play", playListener1);
              let checkmarkIndex = "checkmark-" + id;
              document.getElementById(checkmarkIndex).style.opacity = "1";

              const url = new URL(videoElement.querySelector("source").src);
              const checkedId = srcDictionary[url.pathname];

              console.log("CHECKED ID:", checkedId);
              if (checkedId == "wheel") {
                checkedDictionary["wheel1"] = true;
                checkedDictionary["wheel2"] = true;
              } else {
                checkedDictionary[checkedId] = true;
              }

              console.log("CHECKED DICTIONARY:", checkedDictionary);
              // IF ALL ARE CHECKED, PLAY FULL VIDEO
              const allChecked = Object.values(checkedDictionary).every(
                (value) => value === true
              );
              let endVideoPlayed = false; // add near the top

              // inside the video ended event:
              if (allChecked && !endVideoPlayed) {
                endVideoPlayed = true; // ✅ prevent retrigger
                setTimeout(() => {
                  const endVideo = document.getElementById("video-7");
                  console.log("END VIDEO:", endVideo);
                  currentVideoIndex = 7;
                  endVideo.classList.add("visible");
                  playCompletedVideo(endVideo);
                }, playCompletdVideoDelayMs);
              }
            });
          }
        } else {
          customDragImage.remove();
        }
      }
    }
  }

  function playCompletedVideo(videoElement) {
    const coloredDivs = document.querySelectorAll(".colored-div");

    function playListener() {
      console.log("PLAYING VIDOE");
      coloredDivs.forEach((div) => {
        div.classList.add("grayscale");
      });

      overlayCheckedComponents = false;

      document.removeEventListener("touchstart", handleTouchStart);
      document.removeEventListener("mousedown", handleTouchStart);
    }
    videoElement.addEventListener("play", playListener);

    videoElement.play().catch((error) => {
      console.error("Error attempting to play video:", error);
    });

    let hasTriggered = false;
    const handleTimeUpdate = () => {
      if (
        !hasTriggered &&
        videoElement.currentTime >= videoElement.duration - 3
      ) {
        hasTriggered = true;
        videoElement.removeEventListener("timeupdate", handleTimeUpdate);

        coloredDivs.forEach((div) => {
          div.classList.remove("grayscale");
        });

        overlayCheckedComponents = false;

        document.addEventListener("touchstart", handleTouchStart, {
          passive: false,
        });
        document.addEventListener("mousedown", handleTouchStart, {
          passive: false,
        });
        videoElement.removeEventListener("play", playListener);
        const nextModal = document.getElementById("next-modal");
        nextModal.style.display = "flex";
        setTimeout(() => {
          nextModal.style.display = "none";
          enterGame2();
        }, showNextModalMessageDurationMs);

        console.log("entering game 2");
      }
    };

    videoElement.addEventListener("timeupdate", handleTimeUpdate);
  }

  function showRobot(color) {
    console.log("GIVEN COLOR", color);
    selectedRobot = colorDictionary[color];
  }

  function showExpression(expression) {
    selectedExpression = expression;
  }

  function cropCanvasToContent(canvas) {
    const ctx = canvas.getContext("2d");
    const { width, height } = canvas;
    const imageData = ctx.getImageData(0, 0, width, height);
    const data = imageData.data;

    let top = height,
      bottom = 0,
      left = width,
      right = 0;

    // Scan for the bounding box of non-transparent pixels
    for (let y = 0; y < height; y++) {
      for (let x = 0; x < width; x++) {
        const index = (y * width + x) * 4;
        const alpha = data[index + 3]; // Get alpha channel

        if (alpha > 0) {
          // Non-transparent pixel found
          top = Math.min(top, y);
          bottom = Math.max(bottom, y);
          left = Math.min(left, x);
          right = Math.max(right, x);
        }
      }
    }

    // Calculate the dimensions of the cropped area
    const croppedWidth = right - left + 1;
    const croppedHeight = bottom - top + 1;

    // Create a temporary canvas to hold the cropped image
    const croppedCanvas = document.createElement("canvas");
    const croppedCtx = croppedCanvas.getContext("2d");
    croppedCanvas.width = croppedWidth;
    croppedCanvas.height = croppedHeight;

    // Draw the cropped content onto the temporary canvas
    croppedCtx.putImageData(
      ctx.getImageData(left, top, croppedWidth, croppedHeight),
      0,
      0
    );

    // Convert the cropped canvas to a data URL
    return croppedCanvas.toDataURL("image/png");
  }

  function goToExpressions() {
    console.log("START EXPRESSIONS");
    showExpressionTab = true;
    document.getElementById("next-btn").style.display = "none";
    document.getElementById("finish-btn").style.display = "block";
    const componentContainer = document.querySelector(".component-container");
    if (componentContainer instanceof HTMLElement) {
      componentContainer.style.gridTemplateRows = "repeat(4, 1fr)";
      componentContainer.style.gridTemplateColumns = "repeat(2, 1fr)";
    }
  }

  let tempRobotImage;

  function captureDivs() {
    return new Promise<void>((resolve, reject) => {
      const captureArea = document.getElementById("color-container");
      html2canvas(captureArea, { backgroundColor: null })
        .then((canvas) => {
          const imgDataUrl = cropCanvasToContent(canvas);
          tempRobotImage = imgDataUrl;
          resolve();
        })
        .catch((error) => {
          console.error("Error capturing divs:", error);
          reject(error); // Reject the promise if there's an error
        });
    });
  }

  async function finish() {
    await captureDivs();
    const finishModal = document.getElementById("finish-modal");
    finishModal.style.display = "flex";
  }

  function enterGame2() {
    console.log("entering game 2");
    mode = "game2";
    const game1Divs = document.querySelectorAll(".game1");
    game1Divs.forEach((div) => {
      if (!(div instanceof HTMLElement)) return;
      div.style.transition = "opacity 0.5s";
      div.style.opacity = "0";
      setTimeout(() => {
        div.style.display = "none";
      }, 500);
    });
    // const container = document.getElementById("videoContainer");
    // if (container) container.style.pointerEvents = "none";
    console.log(document.getElementById("next-btn"));
    document.getElementById("next-btn").style.display = "block";
    console.log(document.getElementById("next-btn"));
    const componentContainer = document.querySelector(".component-container");
    if (componentContainer instanceof HTMLElement) {
      componentContainer.style.gridTemplateRows = "repeat(3, 1fr)";
      componentContainer.style.gridTemplateColumns = "repeat(2, 1fr)";
    }
  }

  let currentVideoIndex = 1;

  onMount(() => {
    document.addEventListener("touchstart", handleTouchStart, {
      passive: false,
    });
    document.addEventListener("mousedown", handleTouchStart, {
      passive: false,
    });
    console.log("entering");
    document.getElementById("next-modal").style.display = "none";
    // enterGame2();
  });
</script>

<div class="full-container" bind:this={fullContainer}>
  <div class="modal" id="next-modal" style="display:none">
    <div class="modal-content">
      <p><strong style="width:100%">Nice job!</strong></p>
      <p>Now, pick the color and facial expression of Doodlebot!</p>
    </div>
  </div>

  <div class="modal" id="finish-modal" style="display:none">
    <div class="modal-content">
      <p><strong style="width:100%">Looks amazing!</strong></p>

      <div style="padding:5px">
        <img src={tempRobotImage} style="width:400px" />
      </div>
      <p>Now, let's....</p>
    </div>
  </div>

  <div class="component-container">
    {#if mode === "game1"}
      {#each colors as color, index}
        <div>
          <img
            class="colored-div game1"
            id="color-{index}"
            src={color}
            alt="part {color}"
          />
          <span id="checkmark-{index}" style="opacity:0" class="game1 checkmark"
            >✔️</span
          >
        </div>
      {/each}
    {:else if mode === "game2"}
      {#if showExpressionTab == false}
        {#each game2Colors as color, index}
          <div>
            <div
              on:click={() => showRobot(color)}
              on:touchstart={() => showRobot(color)}
              class="colored-div2 square"
              style="background-color: {color};"
            ></div>
          </div>
        {/each}
      {:else}
        {#each expressions as expression, index}
          <div>
            <div
              on:click={() => showExpression(expression)}
              on:touchstart={() => showExpression(expression)}
              class="colored-div2 rectangle"
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
            ></div>
          </div>
        {/each}
      {/if}
    {/if}
  </div>
  <div class="video-container" id="videoContainer">
    <button
      style="display:none"
      class="next-btn"
      id="next-btn"
      on:touchstart={() => goToExpressions()}
      on:click={() => goToExpressions()}
    >
      Next
    </button>
    <button
      style="display:none"
      class="next-btn"
      id="finish-btn"
      on:touchstart={() => finish()}
      on:click={() => finish()}
    >
      Finish!
    </button>

    {#each videos as videoSrc, index}
      <video
        id="video-{index}"
        style="position: absolute; z-index:0;"
        class="game1"
        muted
        class:visible={index === currentVideoIndex}
      >
        <source src={videoSrc} type="video/mp4" />

        Your browser does not support the video tag.
      </video>
    {/each}

    {#if overlayCheckedComponents}
      {#each Object.entries(layers) as [id, imageSrc], index}
        {#if checkedDictionary[id]}
          <img
            src={imageSrc}
            alt={id}
            class="image-layer game1"
            style="position: absolute; z-index: 10;"
            id={"layer-" + index}
          />
        {/if}
      {/each}
    {/if}

    {#each sounds as soundSrc, index}
      <audio src={soundSrc} id="audio-{index}"></audio>
    {/each}
  </div>
  <div class="color-container" id="color-container">
    {#if selectedRobot && mode == "game2"}
      <div>
        <img class="robot-display" src={selectedRobot} alt="Selected Robot" />
      </div>
      {#if selectedExpression}
        <div>
          <img
            class="robot-display"
            style="width: 100%; position: absolute; bottom: 0px; left: 0px;"
            src={selectedExpression}
            alt="Selected Robot"
          />
        </div>
      {/if}
    {/if}
  </div>
</div>
<div>
  <button
    class="exit-btn"
    on:touchstart={() => context.goToSceneInNextPage(0)}
    on:click={() => context.goToSceneInNextPage(0)}
  >
    EXIT
  </button>
</div>

<style>
  .full-container {
    background-color: #dbdbdb;
    position: relative;
    height: 100%;
    width: 100%;
    display: flex;
    overflow: hidden;
  }

  .exit-btn {
    position: fixed; /* Change to fixed to make sure it stays on top */
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

  .next-btn {
    position: fixed;
    top: 130px;
    /* left: 180px; */
    right: 50px;
    background: linear-gradient(135deg, #4a90e2, #357ae8);
    color: white;
    border: none;
    font-size: 20px;
    font-weight: 600;
    padding: 12px 28px;
    text-align: center;
    cursor: pointer;
    outline: none;
    box-shadow: 0 6px 14px rgba(0, 0, 0, 0.25);
    z-index: 1000;
    transition: all 0.25s ease;
  }

  :global(.grayscale) {
    filter: grayscale(100%);
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
    bottom: -2rem;
    overflow: hidden; /* Ensure content does not overflow */
  }

  .color-container {
    height: 100%;
    width: 70%;
    position: absolute;
    right: 0px;
    top: 0px;
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

  .image-layer {
    animation: fadeIn 2s ease forwards;
    transition: opacity 2s;
  }

  @keyframes fadeIn {
    from {
      opacity: 0;
    }
    to {
      opacity: 0.5;
    }
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

  .robot-display {
    position: absolute;
    top: 150px;
    left: 0px;
    width: 100%;
    transition: opacity 1s; /* Smooth transition for visibility change */
  }

  video,
  .image-layer {
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

  .modal {
    position: fixed;
    left: 0;
    top: 0;
    width: 100%;
    height: 100%;
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
