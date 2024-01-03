import { sveltekit } from "@sveltejs/kit/vite";
import coffee from "vite-plugin-coffee";
import ViteYaml from '@modyfi/vite-plugin-yaml';

/** @type {import('vite').UserConfig} */
const config = {
  plugins: [
    sveltekit(),
    coffee({ jsx: false }),
    ViteYaml()
  ],
  // Allows for local debugging for iOS.
  server: {
    host: true,
  },
};

export default config;
