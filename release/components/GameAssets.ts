  const assetsBasePath = "build-a-doodlebot";

  export type Context = {
    goToSceneInNextPage: (sceneIndex: number) => void;
    fromBase: (src: string) => string;
  };

  export const getAssets = ({ fromBase }: Pick<Context, "fromBase">) => {
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
      srcDictionary,
    };
  };