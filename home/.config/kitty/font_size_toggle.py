from kitty.fast_data_types import get_options


def main(args):
    return float(args[0]) if args else 16.0


@result_handler(no_ui=True)
def handle_result(args, result, target_window_id, boss):
    w = boss.window_for_id(target_window_id)
    if w is None:
        return
    target = float(result)
    if abs(w.screen.font_size - target) > 0.25:
        w.change_font_size(target)
    else:
        w.change_font_size(get_options().font_size)
