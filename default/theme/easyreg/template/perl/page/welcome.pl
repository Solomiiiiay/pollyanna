#!/usr/bin/perl -T

use strict;
use warnings;
use 5.010;

sub GetWelcomePage {
	my $html =
		GetPageHeader('welcome') .
		GetWindowTemplate(GetTemplate('html/page/welcome.template'), 'Welcome') .
		GetWindowTemplate(GetTemplate('html/form/enter.template'), 'Member Entry') .
		GetWindowTemplate(GetTemplate('html/form/guest.template'), 'Guest Entry') .
		#GetWindowTemplate(GetTemplate('html/form/emergency.template'), 'Emergency Contact Form') .
		'<form action="/post.html" method=GET id=compose class=submit name=compose target=_top>' .
		'<span class=advanced>' . GetWriteForm() . '</span>' .
		'</form>' . #todo unhack this
		GetPageFooter('welcome')
	;

	if (GetConfig('admin/js/enable')) {
		my @js = qw(utils profile write puzzle clock easyreg settings);
		$html = InjectJs($html, @js);

		$html = AddAttributeToTag($html, 'input id=member', 'onclick', "if (window.EasyMember) { this.value = 'Meditate...'; setTimeout('EasyMember()', 50); return false; }");
		$html = AddAttributeToTag($html, 'input id=guest', 'onclick', "
			if (document.createElement && document.formRegisterGuest) {
				var d = new Date();
				var n = d.getTime();
				var inputTime = document.createElement('input');
				inputTime.setAttribute('type', 'hidden');
				inputTime.setAttribute('name', 'clicktime');
				inputTime.setAttribute('value', n);
				document.formRegisterGuest.appendChild(inputTime);
			}
		");
	}

	return $html;
} # GetWelcomePage()

1;
