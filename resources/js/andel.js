function initsl() {
	$(function() {
		/* Call the XForm Dispatch mechanism on tag clicks */
		$("#result_table").on('click', '.tag', function() {
			call_xform_event("add_tag", {
				tagname : $(this).text()
			});
			event.preventDefault();
		});
	});
}

function call_xform_event(xfevent, xfpayload) {
	var model = document.getElementById("m_andel")
	XsltForms_xmlevents.dispatch(model, xfevent, null, null, null, null,
			xfpayload);
}

