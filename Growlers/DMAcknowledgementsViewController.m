//
//  DMAcknowledgementsViewController.m
//  Growlers
//
//  Created by Daniel Miedema on 7/27/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMAcknowledgementsViewController.h"
static NSString *stylestring = @"<style>*{margin:0;padding:0;}body {font:13.34px helvetica,arial,freesans,clean,sans-serif;color:black;	line-height:1.4em;background-color: #F8F8F8;padding: 0.7em;}p {margin:1em 0;	line-height:1.5em;}table {	font-size:inherit;font:100%margin:1em;}table th{border-bottom:1px solid #bbb;padding:.2em 1em;}table td{border-bottom:1px solid #ddd;padding:.2em 1em;}input[type=text],input[type=password],input[type=image],textarea{font:99% helvetica,arial,freesans,sans-serif;}select,option{padding:0 .25em;}optgroup{margin-top:.5em;}pre,code{font:12px Monaco,'Courier New','DejaVu Sans Mono','Bitstream Vera Sans Mono',monospace;}pre {margin:1em 0;	font-size:12px;	background-color:#eee;border:1px solid #ddd;padding:5px;line-height:1.5em;color:#444;overflow:auto;-webkit-box-shadow:rgba(0,0,0,0.07) 0 1px 2px inset;-webkit-border-radius:3px;-moz-border-radius:3px;border-radius:3px;}pre code {padding:0;font-size:12px;background-color:#eee;border:none;}code {font-size:12px;background-color:#f8f8ff;color:#444;padding:0 .2em;border:1px solid #dedede;}img{border:0;max-width:100%;}abbr{border-bottom:none;}a{color:#4183c4;text-decoration:none;}a:hover{text-decoration:underline;}a code,a:link code,a:visited code{color:#4183c4;}h2,h3{margin:1em 0;}h1,h2,h3,h4,h5,h6{border:0;}h1{font-size:170%;border-top:4px solid #aaa;padding-top:.5em;margin-top:1.5em;}h1:first-child{margin-top:0;padding-top:.25em;border-top:none;}h2{font-size:150%;margin-top:1.5em;border-top:4px solid #e0e0e0;padding-top:.5em;}h3{margin-top:1em;}hr{border:1px solid #ddd;}ul{margin:1em 0 1em 2em;}ol{margin:1em 0 1em 2em;}ul li,ol li{margin-top:.5em;margin-bottom:.5em;}ul ul,ul ol,ol ol,ol ul{margin-top:0;margin-bottom:0;}blockquote{margin:1em 0;border-left:5px solid #ddd;padding-left:.6em;color:#555;}dt{font-weight:bold;margin-left:1em;}dd{margin-left:2em;margin-bottom:1em;}@media screen and (min-width: 768px) {body {width: 748px;margin:10px auto;}}</style>";

static NSString *AcknowledgementsString = @" \
<h1>Acknowledgements</h1> \
\
<p>This application makes use of the following third party libraries:</p> \
\
<h2>AFNetworking</h2> \
\
<p>Copyright (c) 2011 Gowalla (http://gowalla.com/)</p> \
\
<p>Permission is hereby granted, free of charge, to any person obtaining a copy \
of this software and associated documentation files (the \"Software\"), to deal \
in the Software without restriction, including without limitation the rights \
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell \
copies of the Software, and to permit persons to whom the Software is \
furnished to do so, subject to the following conditions:</p> \
\
<p>The above copyright notice and this permission notice shall be included in \
all copies or substantial portions of the Software.</p> \
\
<p>THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR \
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, \
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE \
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER \
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, \
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN \
THE SOFTWARE.</p> \
\
<h2>DerpKit</h2> \
\
<p>See LICENSE for full license info</p> \
\
<h2>HockeySDK</h2> \
\
<h2>Licenses</h2> \
\
<p>The Hockey SDK is provided under the following license:</p> \
\
<pre><code>The MIT License \
Copyright (c) 2012-2013 HockeyApp, Bit Stadium GmbH. \
All rights reserved. \
\
Permission is hereby granted, free of charge, to any person \
obtaining a copy of this software and associated documentation \
files (the \"Software\"), to deal in the Software without \
restriction, including without limitation the rights to use, \
copy, modify, merge, publish, distribute, sublicense, and/or sell \
copies of the Software, and to permit persons to whom the \
Software is furnished to do so, subject to the following \
conditions: \
\
The above copyright notice and this permission notice shall be \
included in all copies or substantial portions of the Software. \
\
THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, \
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES \
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND \
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT \
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, \
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING \
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR \
OTHER DEALINGS IN THE SOFTWARE. \
</code></pre> \
\
<p>Except as noted below, PLCrashReporter \
is provided under the following license:</p> \
\
<pre><code>Copyright (c) 2008 - 2013 Plausible Labs Cooperative, Inc. \
Copyright (c) 2012 - 2013 HockeyApp, Bit Stadium GmbH. \
All rights reserved. \
\
Permission is hereby granted, free of charge, to any person \
obtaining a copy of this software and associated documentation \
files (the \"Software\"), to deal in the Software without \
restriction, including without limitation the rights to use, \
copy, modify, merge, publish, distribute, sublicense, and/or sell \
copies of the Software, and to permit persons to whom the \
Software is furnished to do so, subject to the following \
conditions: \
\
The above copyright notice and this permission notice shall be \
included in all copies or substantial portions of the Software. \
\
THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, \
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES \
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND \
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT \
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, \
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING \
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR \
OTHER DEALINGS IN THE SOFTWARE. \
</code></pre> \
\
<p>The protobuf-c library, as well as the PLCrashLogWriterEncoding.c \
file are licensed as follows:</p> \
\
<pre><code>Copyright 2008, Dave Benson. \
\
Licensed under the Apache License, Version 2.0 (the \"License\"); \
you may not use this file except in compliance with \
the License. You may obtain a copy of the License \
at http://www.apache.org/licenses/LICENSE-2.0 Unless \
required by applicable law or agreed to in writing, \
software distributed under the License is distributed on \
an \"AS IS\" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY \
KIND, either express or implied. See the License for the \
specific language governing permissions and limitations \
under the License. \
</code></pre> \
\
<p>TTTAttributedLabel is licensed as follows:</p> \
\
<pre><code>Copyright (c) 2011 Mattt Thompson (http://mattt.me/) \
\
Permission is hereby granted, free of charge, to any person \
obtaining a copy of this software and associated documentation \
files (the \"Software\"), to deal in the Software without \
restriction, including without limitation the rights to use, \
copy, modify, merge, publish, distribute, sublicense, and/or sell \
copies of the Software, and to permit persons to whom the \
Software is furnished to do so, subject to the following \
conditions: \
\
The above copyright notice and this permission notice shall be \
included in all copies or substantial portions of the Software. \
\
THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, \
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES \
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND \
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT \
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, \
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING \
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR \
OTHER DEALINGS IN THE SOFTWARE. \
</code></pre> \
\
<h2>TestFlightSDK</h2> \
\
<p>All text and design is copyright © 2010-2013 TestFlight App, Inc.</p> \
\
<p>All rights reserved.</p> \
\
<p>https://testflightapp.com/tos/</p> \
\
<p>Generated by CocoaPods - http://cocoapods.org</p> \
";


@interface DMAcknowledgementsViewController ()
@end

@implementation DMAcknowledgementsViewController

- (void)viewDidLoad
{
    NSLog(@"STRING!_ %@", AcknowledgementsString);
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _webview = [[UIWebView alloc] initWithFrame:self.view.frame];
    [_webview loadHTMLString:[stylestring stringByAppendingString:AcknowledgementsString] baseURL:[[NSBundle mainBundle] bundleURL]];
    [self.view addSubview:_webview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
