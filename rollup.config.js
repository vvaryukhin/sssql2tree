import RollupPluginCommonjs from "@rollup/plugin-commonjs";
import { terser } from "rollup-plugin-terser";

export default {
  input: "src/parser.js",
  output: {
    exports: "auto",
    file: "dist/parser.js",
    format: "cjs",
  },
  plugins: [RollupPluginCommonjs(), terser()],
};
