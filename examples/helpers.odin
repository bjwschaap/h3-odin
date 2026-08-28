package examples

import h3 "../"

assert_success :: proc(err: h3.Error) {
	if !h3.error_is_success(err) {
		panic(h3.error_message(err))
	}
}
