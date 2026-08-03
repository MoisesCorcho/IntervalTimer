# SFX attribution (Freesound, CC0)

Renamed for the app (`sfx_<role>_<nn>.ext`). Original Freesound filenames kept here for license provenance.

## default/ (factory mappings)

| App file | Role(s) | Freesound original |
|----------|---------|-------------------|
| `sfx_tick_01.wav` | `prep_tick`, `phase_warning` (last seconds) | `404151__lilmati__select-granted-01.wav` |
| `sfx_work_start_01.mp3` | `work_start` | `273305__zvinbergsa__whistle.mp3` |
| `sfx_rest_start_01.wav` | `rest_start` | `523763__lilmati__select-granted-06.wav` |
| `sfx_session_complete_01.wav` | `session_complete` | `99625__tec_studio__bell003mono.wav` |

## catalog/ (selectable variants)

### work_start

| App file | Freesound original |
|----------|-------------------|
| `sfx_work_start_02.wav` | `470927__gttorre__wistle.wav` |
| `sfx_work_start_03.wav` | `538422__rosa-orenes256__referee-whistle-sound.wav` |
| `sfx_work_start_04.wav` | `817398__chaos-kid__coach-whistle.wav` |
| `sfx_work_start_05.wav` | `368780__gurie__start-sound-beep.wav` |
| `sfx_work_start_06.wav` | `680825__stomachache__countdown-start.wav` |

### rest_start

| App file | Freesound original |
|----------|-------------------|
| `sfx_rest_start_02.wav` | `455202__lilmati__select-granted-02.wav` |
| `sfx_rest_start_03.wav` | `459344__lilmati__select-granted-03.wav` |
| `sfx_rest_start_04.wav` | `216055__gusgus26__spoon-and-saucer.wav` |
| `sfx_rest_start_05.wav` | `613839__adhdreaming__sous-chef-perc.wav` |
| `sfx_rest_start_06.wav` | `533785__scottstanderfer1__lamp-turning-on.wav` |

### session_complete

| App file | Freesound original |
|----------|-------------------|
| `sfx_session_complete_02.wav` | `717771__1bob__victory-chime.wav` |
| `sfx_session_complete_03.wav` | `842513__pieshelpfuloven__triple_ping_notification_sound_mobile_optimized.wav` |
| `sfx_session_complete_04.mp3` | `851185__okello2020__message-received.mp3` |
| `sfx_session_complete_05.wav` | `376326__bodobobits__rfx.wav` |

### tick (prep / warning variants)

| App file | Freesound original |
|----------|-------------------|
| `sfx_tick_02.wav` | `668355__deltacode__single-tick.wav` |
| `sfx_tick_03.wav` | `547305__starninjas37__tick-tock.wav` |
| `sfx_tick_04.wav` | `369955__mischy__klick_1.wav` |
| `sfx_tick_05.wav` | `72487__rockwehrmann__short01.wav` |
| `sfx_tick_06.wav` | `72488__rockwehrmann__short02.wav` |
| `sfx_tick_07.wav` | `72489__rockwehrmann__short03.wav` |

### click (UI / pause-resume futuros)

| App file | Freesound original |
|----------|-------------------|
| `sfx_click_01.wav` | `219070__annabloom__clickpumppiston.wav` |
| `sfx_click_02.wav` | `342200__christopherderp__videogame-menu-button-click.wav` |
| `sfx_click_03.wav` | `468632__juliantoquica__014_boton1.wav` |
| `sfx_click_04.wav` | `851404__sadiquecat__vibration-oneshot.wav` |

## Naming standard

```text
sfx_<role>_<nn>.<ext>
```

- `role`: `work_start` | `rest_start` | `session_complete` | `tick` | `click`
- `nn`: `01` = factory default (en `default/`); `02+` = catálogo
- Extensión: se conserva la original (`.wav` / `.mp3`)

La categoría de catálogo es **sugerida** por el tipo de clip; en F36 el usuario podrá asignar cualquier id a cualquier slot.
