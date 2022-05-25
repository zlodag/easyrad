function Concerto() {
    (this.globalsToRegister = []),
        (this.getConcertoFrame = function (e) {
            if (e.concertoFrameset) return e.concertoFrameset;
            if (e.self.frames.ConcertoContext) return e;
            try {
                if (e.parent.location && e.parent.location.host && e.self !== e.parent && e.parent.location.host === e.location.host) return this.getConcertoFrame(e.parent);
            } catch (t) { }
            return null;
        }),
        (this.openApplication = function (e) {
            var t = this.getConcertoHome(arguments[1], arguments[2]),
                n = this.getApplicationRedirectorQueryURL(t);
            this.getConcertoFrame(window).frames.ConcertoContext.ContextHelper.openApplication(e, n);
        }),
        (this.openApplicationInWindow = function (e, t, n, r, i, s) {
            this.checkSameServer(n, "openApplicationInWindow");
            var o = this.getApplicationRedirectorQueryURL(concerto.getConcertoHome()),
                u = e.getParameters(),
                a = "ConcertoExternal" + this.getNewWindowHash();
            this.openWindow("", r, i, s, a, this.registerWindow), this.openUrlViaPost(a, o, u);
        }),
        (this.openEntryPointInDockedWindow = function (e, t) {
            var n = this.getConcertoHome();
            this.checkSameServer(n, "openEntryPointInDockedWindow"), (t = t || {});
            var r = t.title || e.displayName || e.entryPointName,
                i = concerto.getApplicationRedirectorQueryURL(n, e);
            if (!this.getConcertoFrame(window).DOCKED_WINDOWS_FEATURE_FLAG_ENABLED) {
                concerto.openInModalDialog({ entryPoint: e, title: r, preferredHeight: 400, preferredWidth: 600 });
                return;
            }
            var s = this.getConcertoFrameset();
            s.WebMain.openEntryPointInDockedWindow({
                entryPoint: { name: e.entryPointName, applicationName: e.applicationName, title: r, url: i },
                isSingleInstance: t.isSingleInstance !== undefined ? !!t.isSingleInstance : !0,
                scope: t.scope,
            });
        }),
        (this.openHelp = function () {
            var e = function (e) {
                if (/^[0-9]+$/.test(e)) return parseInt(e);
                return;
            },
                t = function (t, n, r) {
                    var i = e(r[t]);
                    i ? (r[t] = i) : (i = 400);
                    var s = e(r[n]);
                    return s ? (r[n] = s) : (s = 600), { height: i, width: s };
                },
                n = {};
            arguments.length == 2 ? (n = t(0, 1, arguments)) : arguments.length == 3 && (n = t(1, 2, arguments));
            var r = this.getConcertoHome(arguments[0], arguments[1]);
            this.checkSameServer(r, "openHelp");
            var i = "ConcertoHelp" + this.getNewWindowHash(),
                s = concerto.openWindow("/concerto/BlankLoading.htm", n.height, n.width, "", i, this.registerGlobalWindow),
                o = function () {
                    if (u.readyState !== 4 || s.closed) return;
                    if (u.status >= 200 && u.status < 400) {
                        var e = JSON.parse(u.responseText),
                            t = e.method,
                            n = e.url;
                        if (t === "GET") s.location.replace(n);
                        else {
                            var r = new ParameterList();
                            (r.params = e.contentParams), concerto.openUrlViaPost(i, n, r);
                        }
                    } else u.getResponseHeader("Content-Type").indexOf("text/html") === 0 ? s.document.open().write(u.responseText) : alert(getUnhandledUnknownErrorText());
                },
                u = new XMLHttpRequest();
            (u.onreadystatechange = o), u.open("GET", "/concerto/HelpRedirector"), u.send();
        }),
        (this.openApplicationInModalDialog = function (e, t, n, r, i, s) {
            var o = "Deprecated API method: concerto.openApplicationInModalDialog(). See the Clinical Portal External JavaScript API documentation at https://doki.orionhealth.com";
            return typeof console != "undefined" && (console.warn ? console.warn(o) : console.log), this.openDialog(e, t, n, i, s, window.showModalDialog);
        }),
        (this.openApplicationInModelessDialog = function (e, t, n, r, i, s) {
            return this.checkSameServer(i, "openApplicationInModelessDialog"), this.openDialog(e, t, n, i, s, window.showModelessDialog, this.registerWindow);
        }),
        (this.openUrlInExternal = function (e, t, n, r, i) {
            var s = (t ? t : "ConcertoExternalUrl") + this.getNewWindowHash(),
                o = !(n || r || i);
            return this._openExternal(e, s, n, r, i, o, this.registerWindow);
        }),
        (this.setPatientList = function (e, t) {
            var n = e.getParameters();
            n.setParameter("selectedIndex", t), this.openUrlViaPost("ConcertoContext", this.getConcertoHome() + "/Context.action?operation=setPatientContext", n);
        }),
        (this.setContext = function (e) {
            var t;
            e.secureContexts ? (t = new ContextList(e.contextViewName, e.secureContexts)) : ((t = new ContextList(e.contextViewName)), t.addContext(e), t.setStartIndex(0)),
                t.setApplication(e.application),
                this.setContextList(t, arguments[1], arguments[2]);
        }),
        (this.setContextList = function (e) {
            var t = this.getConcertoHome(arguments[1], arguments[2]);
            this.openUrlViaPost("ConcertoContext", t + "/Context.action?operation=setContext", e.getParameters());
        }),
        (this.popContext = function () {
            var e = this.getConcertoHome(arguments[0], arguments[1]);
            this.getConcertoFrame(window).frames.ConcertoContext.location.replace(e + "/Context.action?operation=popContext");
        }),
        (this.nextContext = function () {
            var e = this.getConcertoHome(arguments[0], arguments[1]);
            this.getConcertoFrame(window).frames.ConcertoContext.location.replace(e + "/Context.action?operation=moveToContext&step=next");
        }),
        (this.previousContext = function () {
            var e = this.getConcertoHome(arguments[0], arguments[1]);
            this.getConcertoFrame(window).frames.ConcertoContext.location.replace(e + "/Context.action?operation=moveToContext&step=previous");
        }),
        (this.openPopupSearch = function (e, t, n, r, i) {
            var s = this.getConcertoHome(i && i.concertoHome),
                o = "height=" + n + ",width=" + r + ",resizable=yes,scrollbars=yes";
            ConcertoSearchWindow.open(s, e, t, o);
        }),
        (this.openLightboxSearch = function (e, t, n, r, i) {
            var s = this.getConcertoFrame(window),
                o;
            s && (o = s.frames.ConcertoContext);
            if (o && o.openContextFrameLightboxSearch) {
                var u = this.getConcertoHome(i && i.concertoHome);
                o.openContextFrameLightboxSearch(u, e, t, n, r);
            } else this.openPopupSearch(e, t, n, r, i);
        }),
        (this.logAuditEvent = function (e) {
            alert("An unsupported action was attempted. Please notify your system administrator with the following details:\nThe concerto.logAuditEvent() method is no longer supported. Calls to it should be removed.");
        }),
        (this.openNewMessage = function (e, t) {
            var n = this.getConcertoHome(arguments[1], arguments[2]);
            this.checkSameServer(n, "openNewMessage");
            var r = this.getConcertoFrameset();
            r.USER_MESSAGING_2_ENABLED
                ? r.WebMain.openNewMessage(e, t)
                : ((this.messageOptions = e), this.openWindow("/concerto/NewMessageWindow.action", 500, 700, "resizable=yes,scrollbars=yes,center=yes", "ConcertoNewMessage" + (Math.random() + "").substring(2), this.registerWindow));
        }),
        (this.isAutomaticallyLoggingOut = function () {
            return this.getConcertoFrameset().WebMain.isClientTimedOut();
        }),
        (this.openInModalDialog = function (e) {
            var t = this.getConcertoFrameset(),
                n = "Portal Modal Dialog Manager is not available.",
                r = this.getConcertoHome(),
                i,
                s;
            t && t.portalModalDialogManager
                ? (e.entryPoint && ((i = this.getApplicationRedirectorQueryURL(r, e.entryPoint)), (s = e.entryPoint.displayName || e.entryPoint.entryPointName)),
                    t.portalModalDialogManager.openModalDialog({
                        title: e.title || s,
                        preferredHeight: e.preferredHeight,
                        preferredWidth: e.preferredWidth,
                        url: i || e.url,
                        message: e.message,
                        callback: e.callback,
                        launchNode: e.launchNode,
                    }))
                : typeof console != "undefined" && (console.warn ? console.warn(n) : console.log);
        }),
        (this.closeModalDialog = function () {
            var e = this.getConcertoFrameset();
            if (!e) return !1;
            var t = e.portalModalDialogManager;
            return t && t.getActiveModalDialog() ? (t.closeModalDialog.apply(t, arguments), !0) : !1;
        }),
        (this.openApplicationInContextInsensitiveWindow = function (e, t, n, r) {
            return this.openWindow(this.getApplicationRedirectorQueryURL(concerto.getConcertoHome(), e), t, n, r, "ConcertoExternal" + this.getNewWindowHash(), this.registerGlobalWindow);
        }),
        (this.openApplicationInContextInsensitiveModelessDialog = function (e, t, n, r) {
            return this.openDialog(e, t, n, concerto.getConcertoHome(), r, window.showModelessDialog, this.registerGlobalWindow);
        }),
        (this.openUrlViaPost = function (e, t, n) {
            var r = document.createElement("form"),
                i = n.params,
                s,
                o;
            r.setAttribute("method", "POST"), r.setAttribute("target", e), r.setAttribute("action", t);
            for (o = 0; o < i.length; o++) (s = document.createElement("input")), (s.type = "hidden"), (s.name = i[o].name), (s.value = i[o].value), (s.defaultValue = i[o].value), r.appendChild(s);
            document.body.appendChild(r), r.submit(), document.body.removeChild(r);
        }),
        (this.openUrlInExternalViaPost = function (e) {
            var t = this.openUrlInExternal(this.getConcertoHome() + "/Blank.htm", e.windowName, e.height, e.width, e.features);
            this.openUrlViaPost(t.name, e.url, e.parameters);
        }),
        (this.getApplicationRedirectorQueryURL = function (e, t) {
            return e + "/" + this.getApplicationRedirectorResource(t);
        }),
        (this.registerWindow = function (e) {
            this.registerGlobal("Window", e);
        }),
        (this.registerGlobalWindow = function (e) {
            this.registerGlobal("GlobalWindow", e);
        }),
        (this.subscribeEvent = function (e, t) {
            this.registerGlobal("EventHandler", { name: e, handler: t });
        }),
        (this.unsubscribeEvent = function (e, t) {
            var n = this.getConcertoFrame(window);
            n && !n.concertoUnloading && this.getConcertoFrameset().WebMain.unregisterEventHandler({ name: e, handler: t });
        }),
        (this.fireEvent = function (e, t) {
            this.registerGlobal("Event", { name: e, data: t });
        }),
        (this.getNewWindowHash = function () {
            return this.getConcertoFrameset().WebMain.newWindowHash;
        }),
        (this.getApplicationRedirectorResource = function (e) {
            var t = new HttpResource("ApplicationRedirector.htm");
            return e && t.addQueryParameters(e.getParameters()), t.getQueryURL();
        }),
        (this.openWindow = function (e, t, n, r, i, s) {
            return this._openExternal(e, i, t, n, r, !1, s);
        }),
        (this._openExternal = function (e, t, n, r, i, s, o) {
            var u;
            return s ? (u = window.open(e, t)) : (u = window.open(e, t, this._getDefaultWindowFeatures(n, r, i))), u.focus(), o.call(this, u), u;
        }),
        (this._getDefaultWindowFeatures = function (e, t, n) {
            var r = n ? n : "resizable=yes,scrollbars=yes";
            return (r += ",height=" + chooseFirstDefined(e, 400) + "px,width=" + chooseFirstDefined(t, 650) + "px"), r;
        }),
        (this.openDialog = function (e, t, n, r, i, s, o) {
            r = this.getConcertoHome(r);
            var u = new ParameterList();
            u.addParameter("applicationName", e.applicationName), u.addParameter("entryPointName", e.entryPointName), u.addParameter("url", this.getApplicationRedirectorResource(e));
            if (typeof i != "string" || i == "") i = "resizable: yes; status: no; help: no";
            if (s != null) {
                var a = s(r + "/Dialog.htm?" + u.getParameterString(), new Arguments(""), i + ";dialogHeight=" + t + "px;dialogWidth=" + n + "px");
                return s == window.showModelessDialog && o.call(this, a), a;
            }
            var f = new this.DialogError();
            throw (alert(f.message), f);
        }),
        (this.checkSameServer = function (e, t) {
            var n = /^[^\/]*\/\/[^\/]*\//;
            if (typeof e != "undefined" && e != null && e != "/concerto" && e.indexOf(location.href.match(n)) != 0) throw new this.CrossSiteError(t);
        }),
        (this.registerGlobal = function (e, t) {
            var n = this.getConcertoFrameset();
            n ? n.WebMain["register" + e](t) : ((this.globalsToRegister[this.globalsToRegister.length] = { type: e, obj: t }), this._pollConcertoFramesetReference());
        }),
        (this.registerGlobals = function () {
            if (this.getConcertoFrameset() != null)
                for (var e = 0; e < this.globalsToRegister.length; e++) {
                    var t = this.globalsToRegister[e];
                    this.registerGlobal(t.type, t.obj);
                }
            else this._pollConcertoFramesetReference();
        }),
        (this.getConcertoFrameset = function () {
            var e = this.getConcertoFrame(window);
            return e ? (e.CONCERTO_FRAMESET ? e : e.concertoFrameset) : null;
        }),
        (this.getHttpConnector = function () {
            var e = this.getHttpConnector.arguments;
            for (var t = 0; t < e.length; t++) if (typeof e[t] != "undefined" && e[t] != null) return e[t];
            return this.getDefaultHttpConnector();
        }),
        (this.getDefaultHttpConnector = function () {
            var e = this.getConcertoFrame(window).http || top.http,
                t = window.top.dialogArguments,
                n = window.top.opener,
                r = !1,
                i;
            while (typeof e == "undefined" && !r)
                try {
                    var i = t ? this.getConcertoFrame(t.win) : this.getConcertoFrame(n);
                    if (i.location.href.search(/\/(Login.htm|Concerto.htm$)/) != -1) return i.http;
                    (t = i.dialogArguments), (n = i.opener);
                } catch (s) {
                    r = !0;
                }
            return e;
        }),
        (this.getDefaultHttpUrlConnector = this.getDefaultHttpConnector),
        (this.getConcertoHome = function (e, t) {
            return e != null && e.constructor == String ? e : t != null && t.constructor == String ? t : "/concerto";
        }),
        (this.CrossSiteError = function (e) {
            this.message = "concerto." + e + " does not support being called from a page hosted on a different server to the Concerto server.";
        }),
        (this.DialogError = function () {
            this.message = "Modal and modeless dialogs are not supported by this browser.";
        }),
        (this._pollConcertoFramesetReference = function () {
            var e = 0,
                t,
                n = this,
                r = 50,
                i = 20;
            t = setInterval(function () {
                (e += 1), n.getConcertoFrameset() ? (clearInterval(t), n.registerGlobals()) : e > i && clearInterval(t);
            }, r);
        });
}
function Application(e, t) {
    (this.applicationName = e),
        (this.entryPointName = t),
        (this.parameters = new ParameterList()),
        this.parameters.addParameter("applicationName", e),
        this.parameters.addParameter("entryPointName", t),
        (this.contextParameters = new ParameterList()),
        this.contextParameters.addParameter("applicationName", e),
        this.contextParameters.addParameter("entryPointName", t),
        this.displayName,
        (this.addQueryParameter = function (e, t) {
            this.parameters.addParameter(e, t), this.contextParameters.addParameter("appQP." + e, t);
        }),
        (this.setSecureInformationToken = function (e) {
            this.addQueryParameter("infoToken", e);
        }),
        (this.getParameters = function () {
            return this.parameters;
        }),
        (this.getContextParameters = function () {
            return this.contextParameters;
        }),
        (this.addQueryParameters = function (e) {
            for (var t = 0; t < e.params.length; t++) {
                var n = e.params[t];
                n.name == "applicationName" || n.name == "entryPointName"
                    ? (this.parameters.setParameter(n.name, n.value), this.contextParameters.setParameter(n.name, n.value))
                    : this.parameters.hasParameter(n.name)
                        ? (this.parameters.setParameter(n.name, n.value), this.contextParameters.setParameter("appQP." + n.name, n.value))
                        : this.addQueryParameter(n.name, n.value);
            }
        }),
        (this.setDisplayName = function (e) {
            this.displayName = e;
        }),
        (this.getDebugName = function () {
            return this.applicationName + " - " + this.entryPointName;
        });
}
function PatientIdentifier(e, t) {
    (this.id = e),
        (this.namespace = t),
        (this.toString = function () {
            return this.id + "@" + this.namespace;
        });
}
function PatientList() {
    (this.application = null),
        (this.hasMore = !1),
        (this.hasPrev = !1),
        (this.patients = []),
        (this.add = function (e) {
            this.patients.push(e);
        }),
        (this.setApplication = function (e) {
            this.application = e;
        }),
        (this.setMore = function (e) {
            this.hasMore = e;
        }),
        (this.setPrev = function (e) {
            this.hasPrev = e;
        }),
        (this.getParameters = function () {
            var e = new ParameterList();
            e.addParameter("hasPrev", this.hasPrev), e.addParameter("hasMore", this.hasMore), this.application != null && e.addParameters(this.application.getContextParameters());
            for (var t = 0; t < this.patients.length; t++) e.addParameter("patientIdentifier." + t, this.patients[t].toString());
            return e;
        });
}
function Context(e, t) {
    (this.contextViewName = e),
        (this.secureContexts = t),
        (this.parameters = new ParameterList()),
        (this.put = function (e, t) {
            this.parameters.addParameter(e, t);
        }),
        (this.setApplication = function (e) {
            this.application = e;
        });
}
function ContextList(e, t) {
    (this.contextViewName = e),
        (this.secureContexts = t),
        (this.contexts = []),
        (this.hasMore = !0),
        (this.hasPrev = !0),
        (this.offset = null),
        this.startIndex,
        (this.total = null),
        (this.setStartIndex = function (e) {
            this.startIndex = e;
        }),
        (this.addContext = function (e) {
            this.contexts[this.contexts.length] = e;
        }),
        (this.setApplication = function (e) {
            this.application = e;
        }),
        (this.getContext = function (e) {
            return this.contexts[e];
        }),
        (this.getParameters = function () {
            var e = new ParameterList();
            e.addParameter("contextViewName", this.contextViewName);
            if (this.secureContexts) {
                e.addParameter("contextToken", this.secureContexts.token), e.addParameter("contextToSetTokenIndex", this.secureContexts.contextToSetTokenIndex);
                for (var t = 0; t < this.secureContexts.contextTokenIndex.length; t++) e.addParameter("contextTokenIndex", this.secureContexts.contextTokenIndex[t]);
            } else {
                e.setParameter("contextToSetIndex", this.startIndex);
                for (var t = 0; t < this.contexts.length; t++) {
                    var n = this.contexts[t].parameters.params;
                    for (var r = 0; r < n.length; r++) e.addParameter("context." + t + "." + n[r].name, n[r].value);
                }
            }
            return (
                this.application != null && e.addParameters(this.application.getContextParameters()),
                e.addParameter("hasPrev", this.hasPrev),
                e.addParameter("hasMore", this.hasMore),
                this.offset != null && e.addParameter("offset", this.offset),
                this.total != null && e.addParameter("total", this.total),
                e
            );
        }),
        (this.getParametersAsJson = function () {
            var e = this.getParameters().params,
                t = {};
            for (var n = 0; n < e.length; n++) t[e[n].name] = e[n].value;
            return t;
        }),
        (this.size = function () {
            return this.contexts.length;
        }),
        (this.setOffset = function (e) {
            this.offset = e;
        }),
        (this.setPrev = function (e) {
            this.hasPrev = e;
        }),
        (this.setMore = function (e) {
            this.hasMore = e;
        }),
        (this.setTotal = function (e) {
            this.total = e;
        });
}
function AuditEvent(e, t, n, r) {
    (this.params = new ParameterList()),
        this.params.addParameter("source", e),
        this.params.addParameter("type", t),
        typeof n != "undefined" && this.params.addParameter("result", n),
        typeof r != "undefined" && this.params.addParameter("message", r),
        (this.addParameter = function (e, t) {
            this.params.addParameter(e, t);
        }),
        (this.getParameterString = function () {
            return this.params.getParameterString();
        });
}
function HttpResource(e, t) {
    (this.url = e),
        (this.method = null),
        (this.http = t),
        (this.headers = new HeaderList()),
        (this.queryParameters = new ParameterList()),
        (this.contentParameters = new ParameterList()),
        (this.responseCode = -1),
        (this.responseMessage = "The response message has not been fetched yet"),
        (this.contentString = "The content string has not been fetched yet"),
        (this.addHeader = function (e, t) {
            this.headers.addHeader(e, t);
        }),
        (this.addQueryParameter = function (e, t) {
            this.queryParameters.addParameter(e, t);
        }),
        (this.addContentParameter = function (e, t) {
            this.contentParameters.addParameter(e, t);
        }),
        (this.setMethod = function (e) {
            this.method = e;
        }),
        (this.getQueryURL = function () {
            var e = this.queryParameters.getParameterString();
            return this.url + (e.length > 0 ? "?" + e : "");
        }),
        (this.postToResource = function (e) {
            return (
                (e = concerto.getHttpConnector(e, this.http)),
                (this.responseCode = e.postToResource(this.getQueryURL(), this.contentParameters.getParameterString(), this.headers.getHeaderNameString(), this.headers.getHeaderValueString())),
                (this.responseMessage = e.getResponseMessage()),
                this.setContentString(e),
                this.responseCode
            );
        }),
        (this.putResource = function (e) {
            return (
                (e = concerto.getHttpConnector(e, this.http)),
                (this.responseCode = e.putResource(this.getQueryURL(), this.contentParameters.getParameterString())),
                (this.responseMessage = e.getResponseMessage()),
                this.setContentString(e),
                this.responseCode
            );
        }),
        (this.deleteResource = function (e) {
            return (e = concerto.getHttpConnector(e, this.http)), (this.responseCode = e.deleteResource(this.getQueryURL())), (this.responseMessage = e.getResponseMessage()), this.setContentString(e), this.responseCode;
        }),
        (this.getResource = function (e) {
            return (
                (e = concerto.getHttpConnector(e, this.http)),
                (this.responseCode = e.getResource(this.getQueryURL(), this.headers.getHeaderNameString(), this.headers.getHeaderValueString())),
                (this.responseMessage = e.getResponseMessage()),
                this.setContentString(e),
                this.responseCode
            );
        }),
        (this.serviceResource = function (e) {
            return (
                (e = concerto.getHttpConnector(e, this.http)),
                this.method == "GET" ? this.getResource(e) : this.method == "POST" ? this.postToResource(e) : this.method == "PUT" ? this.putResource(e) : this.method == "DELETE" ? this.deleteResource(e) : null
            );
        }),
        (this.getResponseCode = function () {
            return this.responseCode;
        }),
        (this.getResponseMessage = function () {
            return this.responseMessage;
        }),
        (this.getContentString = function () {
            return this.contentString;
        }),
        (this.addQueryParameters = function (e) {
            this.queryParameters.addParameters(e);
        }),
        (this.addContentParameters = function (e) {
            this.contentParameters.addParameters(e);
        }),
        (this.getHeaderField = function (e, t) {
            return (t = concerto.getHttpConnector(t, this.http)), t.getHeader(e);
        }),
        (this.setContentString = function (e) {
            e.hasContentString() ? (this.contentString = e.getContentString()) : (this.contentString = null);
        }),
        (this.getMethod = function () {
            return this.method;
        });
}
function getParametersFromForm(e) {
    var t = new ParameterList();
    for (var n = 0; n < e.elements.length; n++) {
        var r = e.elements[n],
            i = r.name,
            s = r.type;
        if (!i) continue;
        if (s == "select-one" || s == "select-multiple") {
            for (var o = 0; o < r.options.length; o++) r.options[o].selected && t.addParameter(i, r.options[o].value);
            t.hasParameter(i) || t.addParameter(i, "");
        } else
            s == "checkbox"
                ? r.value && r.value != "on"
                    ? r.checked && t.addParameter(i, r.value)
                    : r.checked
                        ? t.addParameter(i, "true")
                        : t.addParameter(i, "false")
                : s == "radio"
                    ? r.checked
                        ? t.setParameter(i, r.value)
                        : t.hasParameter(i) || t.addParameter(i, "")
                    : i != "" && s == "button"
                        ? r.title.indexOf("Checked") != -1 && t.addParameter(r.name, r.value)
                        : i != "" && typeof i != "undefined" && t.addParameter(i, r.value);
    }
    return t;
}
function ParameterList() {
    (this.params = []),
        (this.addParameter = function (e, t) {
            this.params[this.params.length] = new NameValue(e, t);
        }),
        (this.addParameters = function (e) {
            this.params = this.params.concat(e.params);
        }),
        (this.removeParameter = function (e) {
            var t = [];
            for (var n = 0; n < this.params.length; n++) this.params[n].name != e && (t[t.length] = this.params[n]);
            this.params = t;
        }),
        (this.hasParameter = function (e) {
            for (var t = 0; t < this.params.length; t++) if (this.params[t].name == e) return !0;
            return !1;
        }),
        (this.setParameter = function (e, t) {
            this.removeParameter(e), this.addParameter(e, t);
        }),
        (this.addFromForm = function (e) {
            this.addParameters(getParametersFromForm(e));
        }),
        (this.getParameterString = function () {
            var e = new StringBuffer();
            for (var t = 0; t < this.params.length; t++) e.append(this.params[t].toString(), t < this.params.length - 1 ? "&" : "");
            return e.toString();
        });
}
function inLightbox(e) {
    return YAHOO.util.Dom.hasClass(e, "LightboxIFrame");
}
function changeLocale(e) {
    var t = HttpPostRequest("ConcertoLocale");
    t.addContentParameter("concertoLocale", e), AsyncConnector.serviceRequest(t, changeLocaleCallback);
}
function changeLocaleCallback(e) {
    var t;
    e.getStatusCode() != 200 && e.getStatusCode() != 204 ? displayResponseError(e) : ((t = concerto.getConcertoFrame(window)), t.location.replace(t.location.href));
}
function displayError(e) {
    alert(e);
}
function hasSafeErrorMessage(e) {
    return e.getHeader ? e.getHeader("X-Response-Code") && e.getHeader("X-Response-Message") : e.getHeaderField ? e.getHeaderField("X-Response-Code") && e.getHeaderField("X-Response-Message") : !1;
}
function getUnhandledUnknownErrorText() {
    var e = concerto.getConcertoFrame(window);
    return e && e.UNHANDLED_UNKNOWN_ERROR_TEXT ? e.UNHANDLED_UNKNOWN_ERROR_TEXT : "An unknown error occurred. Please contact your administrator.";
}
function displayResponseError(e, t) {
    if (hasSafeErrorMessage(e)) {
        var n;
        e.getContent ? (n = e.getContent()) : e.getContentString ? (n = e.getContentString()) : (n = getUnhandledUnknownErrorText()), t ? alert(t + n) : alert(n);
    } else alert(getUnhandledUnknownErrorText());
}
function isOKResponseCode(e) {
    return Math.floor(e / 100) == 2;
}
function isRelocationResponseCode(e) {
    return Math.floor(e / 100) == 3;
}
function isClientErrorResponseCode(e) {
    return Math.floor(e / 100) == 4;
}
function isServerErrorResponseCode(e) {
    return Math.floor(e / 100) == 5;
}
function HeaderList() {
    (this.headers = []),
        (this.addHeader = function (e, t) {
            this.headers[this.headers.length] = new NameValue(e, t);
        }),
        (this.getHeaderNameString = function () {
            var e = "";
            for (var t = 0; t < this.headers.length; t++) (e += this.headers[t].name), t < this.headers.length - 1 && (e += HEADER_SEPARATOR);
            return e;
        }),
        (this.getHeaderValueString = function () {
            var e = "";
            for (var t = 0; t < this.headers.length; t++) (e += this.headers[t].value), t < this.headers.length - 1 && (e += HEADER_SEPARATOR);
            return e;
        });
}
function NameValue(e, t) {
    (this.name = e),
        (this.value = t),
        (this.toString = function () {
            return urlEncode(e) + "=" + urlEncode(t);
        });
}
function Arguments(e) {
    (this.win = window), (this.arguments = e);
}
function chooseFirstDefined() {
    var e = chooseFirstDefined.arguments;
    for (var t = 0; t < e.length; t++) if (e[t] != null && typeof e[t] != "undefined") return e[t];
}
function urlEncode(e) {
    if (e == null) return e;
    e = "" + e;
    var t = new StringBuffer(),
        n = e.length;
    for (var r = 0; r < n; r++) {
        var i = e.charCodeAt(r);
        urlEncode_dontNeedEncoding(i)
            ? t.append(String.fromCharCode(i))
            : i == 32
                ? t.append("+")
                : i <= 127
                    ? t.append(urlEncode_hex[i])
                    : i <= 2047
                        ? t.append(urlEncode_hex[192 | (i >> 6)], urlEncode_hex[128 | (i & 63)])
                        : t.append(urlEncode_hex[224 | (i >> 12)], urlEncode_hex[128 | ((i >> 6) & 63)], urlEncode_hex[128 | (i & 63)]);
    }
    return t.toString();
}
function toLowerCase(e) {
    return String.fromCharCode(e).toLowerCase().charCodeAt(0);
}
function isDigit(e) {
    return !isNaN(String.fromCharCode(e));
}
function urlEncode_dontNeedEncoding(e) {
    return e >= 97 && e <= 122 ? !0 : e >= 65 && e <= 90 ? !0 : e >= 48 && e <= 57 ? !0 : e == 95 ? !0 : e == 46 ? !0 : !1;
}
function urlDecode(e) {
    if (e == null) return e;
    var t = 0,
        n = 0,
        r = new StringBuffer(),
        i = e.length;
    for (var s = 0; s < i; s++) {
        switch ((charCode = e.charCodeAt(s))) {
            case "%".charCodeAt(0):
                charCode = e.charCodeAt(++s);
                var o = (isDigit(charCode) ? charCode - "0".charCodeAt(0) : 10 + toLowerCase(charCode) - "a".charCodeAt(0)) & 15;
                charCode = e.charCodeAt(++s);
                var u = (isDigit(charCode) ? charCode - "0".charCodeAt(0) : 10 + toLowerCase(charCode) - "a".charCodeAt(0)) & 15;
                t = (o << 4) | u;
                break;
            case "+".charCodeAt(0):
                t = " ".charCodeAt(0);
                break;
            default:
                t = charCode;
        }
        (t & 192) == 128 ? (n = (n << 6) | (t & 63)) : (n != 0 && (r.append(String.fromCharCode(n)), (n = 0)), (t & 128) == 0 ? (n = t) : (n = t & 31));
    }
    return n != 0 && r.append(String.fromCharCode(n)), r.toString();
}
function UTF8URLEncoder() {
    this.encode = urlEncode;
}
function URLUTF8Encoder() {
    this.encode = urlEncode;
}
function URLUTF8Decoder() {
    this.decode = urlDecode;
}
function StringBuffer() {
    (this.buf = []),
        (this.append = function () {
            var e = this.append.arguments;
            for (var t = 0; t < e.length; t++) this.buf[this.buf.length] = e[t];
        }),
        (this.toString = function () {
            return this.buf.join("");
        });
}
var HEADER_SEPARATOR = "~;~",
    concerto = new Concerto();
(concerto.CrossSiteError.prototype = new Error()),
    (concerto.CrossSiteError.prototype.name = "CrossSiteError"),
    (concerto.DialogError.prototype = new Error()),
    (concerto.DialogError.prototype.name = "DialogError"),
    (function () {
        function e(e, t, n) {
            if (e.addEventListener) e.addEventListener(t, n);
            else {
                if (!e.attachEvent) throw new Error("Could not attach event: " + t);
                e.attachEvent("on" + t, n);
            }
        }
        function t() {
            concerto.registerGlobal("Activity");
        }
        e(window.document, "click", t), e(window.document, "keyup", t), e(window.document, "mouseover", t), e(window, "scroll", t);
    })();
var Importance = { HIGH: 0, NORMAL: 1, LOW: 2 },
    ConcertoSearchLightbox = {
        concertoHome: null,
        iFrameId: null,
        handler: null,
        open: function (e, t, n, r, i, s, o) {
            hideIFrame(n), (this.concertoHome = e), (this.iFrameId = n), (this.handler = r);
            var u = concerto.getApplicationRedirectorQueryURL(e),
                a = t.getParameters();
            displayIFrameViaPost(n, u, a, s, i, o, ConcertoSearchLightbox.hideHandler), setTimeout(ConcertoSearchLightbox.poll, 250);
        },
        hideHandler: function () {
            var e = frames[ConcertoSearchLightbox.iFrameId];
            e.getResult = function () {
                return null;
            };
        },
        poll: function () {
            var e = frames[ConcertoSearchLightbox.iFrameId];
            if (e.getResult != null) {
                var t = e.getResult();
                hideIFrame(ConcertoSearchLightbox.iFrameId);
                if (t) {
                    var n = {};
                    for (var r in t) {
                        var i = t[r];
                        i.getTime ? (n[r] = new Date(i.getTime())) : (n[r] = i);
                    }
                    ConcertoSearchLightbox.handler(n);
                }
                document.getElementById(ConcertoSearchLightbox.iFrameId).src = ConcertoSearchLightbox.concertoHome + "/Blank.htm";
            } else setTimeout(ConcertoSearchLightbox.poll, 250);
        },
    };
ConcertoSearchWindow = {
    concertoHome: null,
    win: null,
    handler: null,
    token: null,
    open: function (e, t, n, r) {
        this.win != null && !this.win.closed && this.win.close(), (this.concertoHome = e), (this.handler = n), (this.token = "X" + Math.random());
        var i = "X" + (Math.random() + "").substring(2),
            s = concerto.getApplicationRedirectorQueryURL(e),
            o = new ParameterList();
        o.addParameters(t.getParameters()), o.addParameter("concerto.searchResultToken", this.token);
        var u = window.dialogTop && this.getConcertoFrame(window).dialogArguments && this.getConcertoFrame(window).dialogArguments.win ? this.getConcertoFrame(window).dialogArguments.win : window;
        (this.win = u.open("", i, r)),
            concerto.openUrlViaPost(i, s, o),
            this.win.focus(),
            window.addEventListener ? window.addEventListener("unload", ConcertoSearchWindow.close, !1) : window.attachEvent && window.attachEvent("onunload", ConcertoSearchWindow.close),
            setTimeout(ConcertoSearchWindow.poll, 250);
    },
    poll: function () {
        with (ConcertoSearchWindow) {
            var windowClosed = !1;
            try {
                windowClosed = win.closed;
            } catch (e) {
                setTimeout(poll, 250);
                return;
            }
            if (windowClosed) return;
            var result;
            try {
                result = win.getResult();
            } catch (e) {
                setTimeout(poll, 250);
                return;
            }
            var resultCopy = {};
            for (var name in result) {
                var value = result[name];
                value.getTime ? (resultCopy[name] = new Date(value.getTime())) : (resultCopy[name] = value);
            }
            window.focus(), win.close(), handler(resultCopy);
        }
    },
    close: function () {
        ConcertoSearchWindow.win.closed || ConcertoSearchWindow.win.close(),
            window.removeEventListener ? window.removeEventListener("unload", ConcertoSearchWindow.close, !1) : window.detachEvent && window.detachEvent("onunload", ConcertoSearchWindow.close);
    },
};
var urlEncode_hex = new Array(
    "%00",
    "%01",
    "%02",
    "%03",
    "%04",
    "%05",
    "%06",
    "%07",
    "%08",
    "%09",
    "%0A",
    "%0B",
    "%0C",
    "%0D",
    "%0E",
    "%0F",
    "%10",
    "%11",
    "%12",
    "%13",
    "%14",
    "%15",
    "%16",
    "%17",
    "%18",
    "%19",
    "%1A",
    "%1B",
    "%1C",
    "%1D",
    "%1E",
    "%1F",
    "%20",
    "%21",
    "%22",
    "%23",
    "%24",
    "%25",
    "%26",
    "%27",
    "%28",
    "%29",
    "%2A",
    "%2B",
    "%2C",
    "%2D",
    "%2E",
    "%2F",
    "%30",
    "%31",
    "%32",
    "%33",
    "%34",
    "%35",
    "%36",
    "%37",
    "%38",
    "%39",
    "%3A",
    "%3B",
    "%3C",
    "%3D",
    "%3E",
    "%3F",
    "%40",
    "%41",
    "%42",
    "%43",
    "%44",
    "%45",
    "%46",
    "%47",
    "%48",
    "%49",
    "%4A",
    "%4B",
    "%4C",
    "%4D",
    "%4E",
    "%4F",
    "%50",
    "%51",
    "%52",
    "%53",
    "%54",
    "%55",
    "%56",
    "%57",
    "%58",
    "%59",
    "%5A",
    "%5B",
    "%5C",
    "%5D",
    "%5E",
    "%5F",
    "%60",
    "%61",
    "%62",
    "%63",
    "%64",
    "%65",
    "%66",
    "%67",
    "%68",
    "%69",
    "%6A",
    "%6B",
    "%6C",
    "%6D",
    "%6e",
    "%6F",
    "%70",
    "%71",
    "%72",
    "%73",
    "%74",
    "%75",
    "%76",
    "%77",
    "%78",
    "%79",
    "%7A",
    "%7B",
    "%7C",
    "%7D",
    "%7e",
    "%7F",
    "%80",
    "%81",
    "%82",
    "%83",
    "%84",
    "%85",
    "%86",
    "%87",
    "%88",
    "%89",
    "%8A",
    "%8B",
    "%8C",
    "%8D",
    "%8e",
    "%8F",
    "%90",
    "%91",
    "%92",
    "%93",
    "%94",
    "%95",
    "%96",
    "%97",
    "%98",
    "%99",
    "%9A",
    "%9B",
    "%9C",
    "%9D",
    "%9E",
    "%9F",
    "%A0",
    "%A1",
    "%A2",
    "%A3",
    "%A4",
    "%A5",
    "%A6",
    "%A7",
    "%A8",
    "%A9",
    "%AA",
    "%AB",
    "%AC",
    "%AD",
    "%AE",
    "%AF",
    "%B0",
    "%B1",
    "%B2",
    "%B3",
    "%B4",
    "%B5",
    "%B6",
    "%B7",
    "%B8",
    "%B9",
    "%BA",
    "%BB",
    "%BC",
    "%BD",
    "%BE",
    "%BF",
    "%C0",
    "%C1",
    "%C2",
    "%C3",
    "%C4",
    "%C5",
    "%C6",
    "%C7",
    "%C8",
    "%C9",
    "%CA",
    "%CB",
    "%CC",
    "%CD",
    "%CE",
    "%CF",
    "%D0",
    "%D1",
    "%D2",
    "%D3",
    "%D4",
    "%D5",
    "%D6",
    "%D7",
    "%D8",
    "%D9",
    "%DA",
    "%DB",
    "%DC",
    "%DD",
    "%DE",
    "%DF",
    "%E0",
    "%E1",
    "%E2",
    "%E3",
    "%E4",
    "%E5",
    "%E6",
    "%E7",
    "%E8",
    "%E9",
    "%EA",
    "%EB",
    "%EC",
    "%ED",
    "%EE",
    "%EF",
    "%F0",
    "%F1",
    "%F2",
    "%F3",
    "%F4",
    "%F5",
    "%F6",
    "%F7",
    "%F8",
    "%F9",
    "%FA",
    "%FB",
    "%FC",
    "%FD",
    "%FE",
    "%FF"
),
    HTTP_OK = 200,
    HTTP_CREATED = 201,
    HTTP_ACCEPTED = 202,
    HTTP_NOT_AUTHORITATIVE = 203,
    HTTP_NO_CONTENT = 204,
    HTTP_RESET = 205,
    HTTP_PARTIAL = 206,
    HTTP_MULT_CHOICE = 300,
    HTTP_MOVED_PERM = 301,
    HTTP_MOVED_TEMP = 302,
    HTTP_SEE_OTHER = 303,
    HTTP_NOT_MODIFIED = 304,
    HTTP_USE_PROXY = 305,
    HTTP_BAD_REQUEST = 400,
    HTTP_UNAUTHORIZED = 401,
    HTTP_PAYMENT_REQUIRED = 402,
    HTTP_FORBIDDEN = 403,
    HTTP_NOT_FOUND = 404,
    HTTP_BAD_METHOD = 405,
    HTTP_NOT_ACCEPTABLE = 406,
    HTTP_PROXY_AUTH = 407,
    HTTP_CLIENT_TIMEOUT = 408,
    HTTP_CONFLICT = 409,
    HTTP_GONE = 410,
    HTTP_LENGTH_REQUIRED = 411,
    HTTP_PRECON_FAILED = 412,
    HTTP_ENTITY_TOO_LARGE = 413,
    HTTP_REQ_TOO_LONG = 414,
    HTTP_UNSUPPORTED_TYPE = 415,
    HTTP_SERVER_ERROR = 500,
    HTTP_INTERNAL_ERROR = 501,
    HTTP_BAD_GATEWAY = 502,
    HTTP_UNAVAILABLE = 503,
    HTTP_GATEWAY_TIMEOUT = 504,
    HTTP_VERSION = 505;
