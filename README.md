# Build-doodlebot-storybook-activity-suede

This repo is a [suede dependency](https://github.com/pmalacho-mit/suede).

To see the installable source code, please checkout the [release branch](https://github.com/mitmedialab/build-doodlebot-storybook-activity-suede/tree/release).

## Installation

```bash
bash <(curl https://suede.sh/install-release) --repo mitmedialab/build-doodlebot-storybook-activity-suede
```

<details>
<summary>
See alternative to using <a href="https://github.com/pmalacho-mit/suede#suedesh">suede.sh</a> script proxy
</summary>

```bash
bash <(curl https://raw.githubusercontent.com/pmalacho-mit/suede/refs/heads/main/scripts/install-release.sh) --repo mitmedialab/build-doodlebot-storybook-activity-suede
```

</details>

### Refactor ideas

- make each app state a different component (or [snippet](https://svelte.dev/docs/svelte/snippet)!!!)
  - enables testing pieces in isolation and greatly simplifies complexity
- less magic numbers
- (done) use relative position & sizing to ensure that overlays work as expected
- (done) add types!
