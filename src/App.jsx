import { useState } from 'react';
import { ArrowRight, ArrowUpRight, Menu, X, ShieldCheck, Landmark, Plane, Wallet, Building2, ReceiptText, Clock3, Globe2, LockKeyhole, ChevronDown, Check, BadgeCheck, ChartNoAxesCombined } from 'lucide-react';

const nav = [['Our model','#model'],['Services','#services'],['Security','#security'],['About','#about']];
const steps = [
  {n:'01',title:'Join the network',text:'Pilots and virtual airlines apply for an account. Every account is reviewed and linked to a verified community identity.',icon:BadgeCheck},
  {n:'02',title:'Fund your operation',text:'The bank allocates virtual operating capital to registered airlines using a transparent activity-based model.',icon:Landmark},
  {n:'03',title:'Move money with confidence',text:'Pay crews, transfer balances and issue controlled cheques through the banking portal.',icon:ArrowUpRight},
  {n:'04',title:'Daily clearing',text:'Submitted cheques enter a staff review queue and are settled during the next banking session.',icon:ReceiptText}
];
const services = [
  {icon:Wallet,title:'Personal accounts',text:'A dedicated account for every eligible pilot, with a clear transaction history and payment records.'},
  {icon:Building2,title:'Corporate banking',text:'Registered virtual airlines operate as companies, manage working capital and pay their crews.'},
  {icon:ReceiptText,title:'Cheque services',text:'Issue private, traceable cheques with account-specific cheque books and staff-controlled clearing.'},
  {icon:ChartNoAxesCombined,title:'Net banking',text:'A secure online space for balances, transfers, statements and account administration.'}
];

function App(){
  const [menuOpen,setMenuOpen]=useState(false);
  const [faqOpen,setFaqOpen]=useState(0);
  const [notice,setNotice]=useState(false);
  const faqs=[
    ['Is this a real-money bank?','No. Bank Regensburg is a fictional banking network for the Infinite Flight community. It does not accept deposits, hold real funds, provide financial services or represent a licensed financial institution.'],
    ['How does an airline receive operating capital?','Registered virtual airlines receive virtual funds based on a published allocation formula that considers pilot count, fleet and route activity. The formula and review process should be visible to participating companies.'],
    ['When are cheques processed?','The proposed clearing window closes at 16:30 Zulu on banking days. Weekends and published bank holidays are non-clearing days. Cheques submitted after the cut-off move to the next banking session.'],
    ['How do I open an account?','Account applications and identity checks will be handled through the official community channels when onboarding opens. Never share passwords or sensitive personal information in Discord.']
  ];
  const closeMenu=()=>setMenuOpen(false);
  return <div className="site-shell">
    <div className="topline"><span className="live-dot"/> VIRTUAL BANKING NETWORK <span className="top-sep">/</span> BUILT FOR INFINITE FLIGHT</div>
    <header className="header">
      <a className="brand" href="#" aria-label="Bank Regensburg home"><span className="brand-mark">R</span><span className="brand-copy"><strong>BANK REGENSBURG</strong><small>THE AVIATION BANKING NETWORK</small></span></a>
      <nav className={menuOpen?'nav nav-open':'nav'}>{nav.map(([label,href])=><a key={label} href={href} onClick={closeMenu}>{label}</a>)}<a className="nav-cta" href="#access" onClick={closeMenu}>Portal access <ArrowUpRight size={15}/></a></nav>
      <button className="menu-toggle" onClick={()=>setMenuOpen(!menuOpen)} aria-label="Toggle navigation">{menuOpen?<X/>:<Menu/>}</button>
    </header>
    <main>
      <section className="hero">
        <div className="hero-grid"/>
        <div className="hero-copy">
          <div className="eyebrow"><span className="eyebrow-line"/> A BANK BUILT AROUND AVIATION</div>
          <h1>Where virtual<br/><em>operations</em> meet<br/>real-world banking.</h1>
          <p className="hero-lede">A complete banking framework for the Infinite Flight community. Accounts, company capital, crew payments and cheque clearing — brought together under one trusted institution.</p>
          <div className="hero-actions"><a className="button button-primary" href="#model">Explore the bank <ArrowRight size={17}/></a><a className="button button-quiet" href="#access">Portal information <ArrowUpRight size={16}/></a></div>
          <div className="hero-footnote"><ShieldCheck size={15}/> COMMUNITY-OPERATED <span/> VIRTUAL CURRENCY ONLY</div>
        </div>
        <div className="hero-visual">
          <div className="orbit orbit-one"/><div className="orbit orbit-two"/>
          <div className="visual-label label-top"><span>EST.</span><strong>REGENSBURG</strong></div>
          <div className="bank-card">
            <div className="card-head"><span className="card-monogram">R</span><span className="card-chip">PRIVATE NETWORK<br/>MEMBER INSTITUTION</span></div>
            <div className="card-center"><small>THE BANKING NETWORK</small><strong>Built for the<br/>virtual skies.</strong></div>
            <div className="card-foot"><span>REGENSBURG</span><span>IF COMMUNITY</span></div>
          </div>
          <div className="floating-stamp"><Globe2 size={17}/><span>INTERNATIONAL<br/><b>BY DESIGN</b></span></div>
          <div className="visual-coordinates">49°01' N&nbsp;&nbsp; 12°06' E</div>
        </div>
        <div className="hero-bottom"><span>01 / A NEW STANDARD FOR VIRTUAL AVIATION</span><span>SCROLL TO DISCOVER ↓</span></div>
      </section>
      <section className="trust-strip"><div><span className="strip-number">01</span><strong>PERSONAL</strong><small>Individual accounts</small></div><div><span className="strip-number">02</span><strong>CORPORATE</strong><small>Virtual airline accounts</small></div><div><span className="strip-number">03</span><strong>CONTROLLED</strong><small>Staff-reviewed clearing</small></div><div><span className="strip-number">04</span><strong>CONNECTED</strong><small>Discord-led operations</small></div></section>
      <section className="section model-section" id="model">
        <div className="section-kicker">01 — THE OPERATING MODEL</div>
        <div className="section-heading"><h2>A bank with a<br/><em>flight plan.</em></h2><p>Our physical branch is digital by nature. Discord is the community hub where members connect with bank staff; the website is where account activity is securely managed and recorded.</p></div>
        <div className="model-layout"><div className="model-aside"><div className="aside-icon"><Landmark size={24}/></div><h3>One institution.<br/>A connected community.</h3><p>Every movement of virtual funds follows a recorded process, with defined roles and an auditable trail.</p><a href="#security">Our principles <ArrowUpRight size={15}/></a></div><div className="steps">{steps.map(s=><article className="step" key={s.n}><span className="step-number">{s.n}</span><div className="step-icon"><s.icon size={20}/></div><div><h3>{s.title}</h3><p>{s.text}</p></div><ArrowUpRight className="step-arrow" size={17}/></article>)}</div></div>
      </section>
      <section className="section services-section" id="services"><div className="section-kicker">02 — BANKING SERVICES</div><div className="section-heading"><h2>Everything in its<br/><em>right place.</em></h2><p>Purpose-built services for the people who fly, manage and grow virtual airlines.</p></div><div className="service-grid">{services.map((s,i)=><article className="service-card" key={s.title}><div className="service-top"><span>0{i+1}</span><s.icon size={22}/></div><h3>{s.title}</h3><p>{s.text}</p><span className="service-rule"/></article>)}</div></section>
      <section className="clearing-section"><div className="clearing-copy"><div className="section-kicker light-kicker">03 — CHEQUE CLEARING</div><h2>Every cheque.<br/><em>Accounted for.</em></h2><p>Cheque books are issued against approved accounts. A cheque is completed privately in the member portal, then routed to the bank's staff queue for verification and settlement.</p><div className="clearing-note"><Clock3 size={18}/><span><b>Daily cut-off · 16:30 Zulu</b><small>Monday to Friday, excluding published bank holidays.</small></span></div></div><div className="cheque-panel"><div className="cheque-head"><span>REG- / CLEARING NOTE</span><span className="cheque-status"><i/> CONTROLLED</span></div><div className="cheque-watermark">R</div><div className="cheque-field"><small>PAYMENT INSTRUMENT</small><strong>Private cheque submission</strong></div><div className="cheque-lines"><span>ISSUED BY <b>Verified account holder</b></span><span>REVIEWED BY <b>Bank clearing staff</b></span><span>SETTLEMENT <b>After approval</b></span></div><div className="cheque-footer"><span>TRACEABLE · REVIEWABLE · RECORDED</span><ShieldCheck size={18}/></div></div></section>
      <section className="section security-section" id="security"><div className="section-kicker">04 — TRUST & GOVERNANCE</div><div className="security-layout"><div><h2>Trust is built<br/>into the <em>process.</em></h2><p className="security-intro">Privacy and accountability are not optional extras. They are the foundation of every account and every transaction.</p></div><div className="principles"><div><LockKeyhole/><span><b>Private by default</b><small>Cheque details are visible only to the parties and authorised bank staff who need them.</small></span></div><div><ShieldCheck/><span><b>Role-based access</b><small>Members, company officers, clearing staff and administrators receive separate permissions.</small></span></div><div><ReceiptText/><span><b>Complete audit trail</b><small>Every approval, rejection, transfer and adjustment is recorded with a responsible staff identity.</small></span></div></div></div></section>
      <section className="faq-section" id="about"><div className="section-kicker">05 — THE DETAILS</div><div className="faq-layout"><div><h2>Good to<br/><em>know.</em></h2><p>Clear rules make a stronger institution. Here are the first things every member should know.</p></div><div className="faq-list">{faqs.map(([q,a],i)=><div className={'faq-item '+(faqOpen===i?'faq-active':'')} key={q}><button onClick={()=>setFaqOpen(faqOpen===i?-1:i)}><span>{q}</span><ChevronDown size={18}/></button>{faqOpen===i&&<p>{a}</p>}</div>)}</div></div></section>
      <section className="access-section" id="access"><div className="access-emblem">R</div><div className="section-kicker light-kicker">THE NEXT DEPARTURE</div><h2>Your place in the<br/><em>network starts here.</em></h2><p>Account onboarding and member services will be introduced in phases. Join the official community for launch announcements and assistance.</p><button className="button button-light" onClick={()=>setNotice(true)}>Onboarding coming soon <ArrowUpRight size={17}/></button>{notice&&<div className="notice"><Check size={15}/> Portal access is not open yet. Follow the official Discord for launch updates.</div>}<small className="access-disclaimer">Bank Regensburg is a fictional, community-run virtual banking project. No real money or regulated financial services are involved.</small></section>
    </main>
    <footer className="footer"><a className="brand footer-brand" href="#"><span className="brand-mark">R</span><span className="brand-copy"><strong>BANK REGENSBURG</strong><small>THE AVIATION BANKING NETWORK</small></span></a><span className="footer-copy">© 2026 BANK REGENSBURG · A VIRTUAL INSTITUTION</span><a href="#top" onClick={e=>{e.preventDefault();window.scrollTo({top:0,behavior:'smooth'})}}>BACK TO TOP ↑</a></footer>
  </div>
}
export default App;
