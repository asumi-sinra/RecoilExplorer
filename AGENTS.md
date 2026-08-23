# Repository Guidelines

## Project Structure & Module Organization

RecoilExplorer is a Godot 4.2 project. `project.godot` defines input actions and the `Input_Mode` autoload. Gameplay code lives in `scripts/`: player and entry-point logic are at the top level, while `world/data`, `world/generators`, and `world/room` separate map state, procedural generation, and room transitions. Scene files mirror those domains under `scenes/` (`player/`, `guns/`, and `rooms/`). Reusable Godot resources live in `resources/biome/` and `resources/rooms/`. Keep generated editor state in `.godot/` untracked.

## Build, Test, and Development Commands

- `godot --editor --path .` opens the project in Godot 4.2 or a compatible Godot 4 release.
- `godot --headless --editor --path . --quit` imports assets and checks that scenes and scripts load without parser errors; run this before submitting changes.
- `godot --path . --editor scenes/Main.tscn` opens the primary scene directly when reviewing world-generation changes.

No export presets are committed, so create platform exports through the Godot editor rather than assuming a repository build command.

## Coding Style & Naming Conventions

Follow Godot's GDScript conventions: tabs for indentation, `snake_case` for variables and functions, `PascalCase` for `class_name` types and scene/script filenames, and `UPPER_SNAKE_CASE` for constants. Add parameter and return types to new APIs where practical, as in `func generate(world: WorldData) -> void`. Keep scene paths and resource references under `res://`; move or rename them through the editor so references update safely. Match the surrounding Japanese or English comment style, but explain intent rather than restating code.

## Testing Guidelines

There is currently no automated test framework or coverage target. Validate every change with the headless load check, then play the affected scene in the editor. For generator changes, exercise several runs because biome, gate, road, and room selection are randomized. Confirm room exits, spawn markers, keyboard/mouse input, and gamepad input when those areas change. If tests are introduced, place them in `tests/` and name files `test_<feature>.gd`.

## Commit & Pull Request Guidelines

Recent history uses short checkpoint subjects and version labels (for example, `0.8.4`). Keep subjects concise, but make them descriptive and action-oriented, such as `Fix room exit spawn selection`. Limit each commit to one coherent change. Pull requests should summarize behavior changes, list manual validation performed, link related issues, and include screenshots or a short capture for visible scene, UI, or camera changes. Do not commit `.godot/` contents or temporary scene files such as `*.tmp`.

Godot version: 4.2.2 stable

- 変更する.gdは全文を提示する
- 既存アーキテクチャを勝手に再設計しない
- warnings as errors を考慮する
- Godot 4.2.2のAPIを使う
- road_bitsは DOWN, LEFT, UP, RIGHT の順
- まず原因調査、その後に修正
