define(["i18next"],function(a){function b(a,b){d.setItem(c+"."+a,JSON.stringify(b))}var c="CRM.lang",d=window.localStorage,e=function(a){var b=d.getItem(c+"."+a);return null!==b?JSON.parse(b):(console.warn("SFDC/lang: key "+a+" not found"),null)};return{initialize:function(){console.log("SFDC/lang: initialize"),b("default",{search:a.t("search.search"),phoneNumber:a.t("search.phoneNumber"),name:a.t("search.name"),email:a.t("search.email"),account:a.t("search.account"),address:a.t("search.address")}),b("case",{search:a.t("search.search"),caseSearch:a.t("search.caseSearch"),caseNumber:a.t("search.caseNumber"),subject:a.t("search.subject"),account:a.t("search.account"),name:a.t("search.name"),dateCreated:a.t("search.dateCreated")})},getText:e}});