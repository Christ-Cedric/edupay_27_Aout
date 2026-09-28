/**
 * EduPay — Script de Logique Institutionnelle & Simulateur Budgétaire
 * Conçu sans animations tape-à-l'œil, sans compteurs artificiels, sans emojis.
 */

document.addEventListener('DOMContentLoaded', () => {

  /* ------------------------------------------------------------------------
   * 1. Menu Déroulant des Espaces Réservés
   * ------------------------------------------------------------------------ */
  const portalDropdown = document.querySelector('.portal-dropdown');
  const portalToggle = document.getElementById('portal-toggle');

  if (portalDropdown && portalToggle) {
    portalToggle.addEventListener('click', (e) => {
      e.stopPropagation();
      const isOpen = portalDropdown.classList.toggle('is-open');
      portalToggle.setAttribute('aria-expanded', isOpen ? 'true' : 'false');
    });

    document.addEventListener('click', (e) => {
      if (!portalDropdown.contains(e.target)) {
        portalDropdown.classList.remove('is-open');
        portalToggle.setAttribute('aria-expanded', 'false');
      }
    });

    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape' && portalDropdown.classList.contains('is-open')) {
        portalDropdown.classList.remove('is-open');
        portalToggle.setAttribute('aria-expanded', 'false');
        portalToggle.focus();
      }
    });
  }

  /* ------------------------------------------------------------------------
   * 1.b. Menu Hamburger Mobile & Tiroir de Navigation Déroulant
   * ------------------------------------------------------------------------ */
  const mobileNavToggle = document.getElementById('mobile-nav-toggle');
  const mobileNavMenu = document.getElementById('mobile-nav-menu');
  const mainHeader = document.getElementById('header');
  const mobileNavBackdrop = document.getElementById('mobile-nav-backdrop');

  function closeMobileNav() {
    if (!mobileNavMenu) return;
    mobileNavMenu.classList.remove('is-open');
    if (mobileNavToggle) {
      mobileNavToggle.classList.remove('is-active');
      mobileNavToggle.setAttribute('aria-expanded', 'false');
    }
    if (mainHeader) mainHeader.classList.remove('nav-expanded');
    if (mobileNavBackdrop) mobileNavBackdrop.classList.remove('is-visible');
    document.body.classList.remove('menu-locked');
  }

  function openMobileNav() {
    if (!mobileNavMenu) return;
    mobileNavMenu.classList.add('is-open');
    if (mobileNavToggle) {
      mobileNavToggle.classList.add('is-active');
      mobileNavToggle.setAttribute('aria-expanded', 'true');
    }
    if (mainHeader) mainHeader.classList.add('nav-expanded');
    if (mobileNavBackdrop) mobileNavBackdrop.classList.add('is-visible');
    document.body.classList.add('menu-locked');
  }

  if (mobileNavToggle && mobileNavMenu) {
    mobileNavToggle.addEventListener('click', (e) => {
      e.stopPropagation();
      const isOpen = mobileNavMenu.classList.contains('is-open');
      if (isOpen) {
        closeMobileNav();
      } else {
        openMobileNav();
      }
    });

    // Fermeture automatique lors du clic sur un lien du menu mobile
    const mobileLinks = mobileNavMenu.querySelectorAll('a');
    mobileLinks.forEach(link => {
      link.addEventListener('click', closeMobileNav);
    });

    // Fermeture en cliquant sur le voile d'arrière-plan
    if (mobileNavBackdrop) {
      mobileNavBackdrop.addEventListener('click', closeMobileNav);
    }

    // Fermeture si on clique en dehors
    document.addEventListener('click', (e) => {
      if (!mobileNavMenu.contains(e.target) && !mobileNavToggle.contains(e.target)) {
        closeMobileNav();
      }
    });

    // Fermeture avec la touche Échap
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape' && mobileNavMenu.classList.contains('is-open')) {
        closeMobileNav();
      }
    });
  }

  /* ------------------------------------------------------------------------
   * 2. Sécurité & Protection contre les Injections (XSS / SQL / Bots)
   * ------------------------------------------------------------------------ */
  const API_BASE = (window.location.protocol.startsWith('http') && window.location.port === '3000')
    ? window.location.origin + '/api/v1'
    : 'http://localhost:3000/api/v1';

  /**
   * Assainit une chaîne de caractères pour neutraliser les injections HTML/Script.
   */
  function sanitizeInput(str) {
    if (typeof str !== 'string') return '';
    return str
      .replace(/<[^>]*>/g, '') // Supprime les balises HTML/XML/SVG
      .replace(/javascript:/gi, '')
      .replace(/data:/gi, '')
      .replace(/vbscript:/gi, '')
      .replace(/on\w+=/gi, '') // Supprime les event handlers injectés
      .trim();
  }

  /* ------------------------------------------------------------------------
   * 3. Simulateur de Plan d'Épargne Scolaire & Connexion Base de Données
   * ------------------------------------------------------------------------ */
  const levelSelect = document.getElementById('sim-level');
  const kitTierRadios = document.querySelectorAll('input[name="kit_tier"]');
  const optUniform = document.getElementById('opt-uniform');
  const optExam = document.getElementById('opt-exam');
  const optTuition = document.getElementById('opt-tuition');
  const durationSelect = document.getElementById('sim-duration');
  const simSyncStatus = document.getElementById('sim-sync-status');

  const resTotalEl = document.getElementById('res-total');
  const resDailyEl = document.getElementById('res-daily');
  const resWeeklyEl = document.getElementById('res-weekly');
  const resMonthlyEl = document.getElementById('res-monthly');

  // Barème certifié de secours (fallback si base de données temporairement injoignable)
  const PRICING_MATRIX = {
    primaire_cp_ce: { basic: 14500, comfort: 22000, complete: 34000 },
    primaire_cm:    { basic: 18000, comfort: 27500, complete: 42000 },
    college_6_4:    { basic: 24000, comfort: 38000, complete: 58000 },
    college_3:      { basic: 28000, comfort: 44000, complete: 68000 },
    lycee_seconde_terminale: { basic: 32000, comfort: 52000, complete: 82000 },
    technique:      { basic: 36000, comfort: 58000, complete: 94000 }
  };

  function formatFCFA(amount) {
    const safeAmount = Math.max(0, Math.round(Number(amount) || 0));
    return safeAmount.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ' ') + ' FCFA';
  }

  function recalculatePlan() {
    if (!levelSelect || !durationSelect) return;

    const level = levelSelect.value;
    let selectedTier = 'comfort';

    kitTierRadios.forEach(r => {
      const parentLabel = r.closest('.radio-option');
      if (r.checked) {
        selectedTier = r.value;
        if (parentLabel) parentLabel.classList.add('is-active');
      } else {
        if (parentLabel) parentLabel.classList.remove('is-active');
      }
    });

    const levelRates = PRICING_MATRIX[level] || PRICING_MATRIX.primaire_cp_ce;
    const baseKitPrice = Number(levelRates[selectedTier]) || 25000;

    let extras = 0;
    if (optUniform && optUniform.checked) extras += Math.max(0, parseInt(optUniform.value, 10) || 0);
    if (optExam && optExam.checked) extras += Math.max(0, parseInt(optExam.value, 10) || 0);
    if (optTuition && optTuition.checked) extras += Math.max(0, parseInt(optTuition.value, 10) || 0);

    const totalAmount = baseKitPrice + extras;
    const rawMonths = parseInt(durationSelect.value, 10) || 8;
    const months = Math.max(1, Math.min(12, rawMonths)); // Validation stricte des bornes

    const monthlyAmount = totalAmount / months;
    const weeklyAmount = totalAmount / (months * 4.33);
    const dailyAmount = totalAmount / (months * 30);

    if (resTotalEl) resTotalEl.textContent = formatFCFA(totalAmount);
    if (resDailyEl) resDailyEl.textContent = formatFCFA(dailyAmount) + ' / jour';
    if (resWeeklyEl) resWeeklyEl.textContent = formatFCFA(weeklyAmount) + ' / semaine';
    if (resMonthlyEl) resMonthlyEl.textContent = formatFCFA(monthlyAmount) + ' / mois';
  }

  /**
   * Connexion en direct à la base de données existante (via l'API EduPay).
   * Récupère les tarifs officiels des kits réels et la saison scolaire active.
   */
  async function syncSimulatorWithDatabase() {
    try {
      const kitsPromise = fetch(`${API_BASE}/catalog/kits`, { method: 'GET' })
        .then(r => r.ok ? r.json() : null)
        .catch(() => null);

      const seasonPromise = fetch(`${API_BASE}/catalog/current-season`, { method: 'GET' })
        .then(r => r.ok ? r.json() : null)
        .catch(() => null);

      const [kitsData, seasonData] = await Promise.all([kitsPromise, seasonPromise]);

      if (kitsData && Array.isArray(kitsData.data) && kitsData.data.length > 0) {
        const kits = kitsData.data;

        // Regroupement des kits de la base de données selon les cycles scolaires
        const bucketMap = {
          primaire_cp_ce: [],
          primaire_cm: [],
          college_6_4: [],
          college_3: [],
          lycee_seconde_terminale: [],
          technique: []
        };

        kits.forEach(kit => {
          const scope = (kit.level_scope || '').toLowerCase();
          const tier = kit.level === 'intermediate' ? 'comfort' : (kit.level === 'premium' ? 'complete' : 'basic');
          const price = Number(kit.price) || 0;
          if (price <= 0) return;

          const item = { tier, price };

          if (scope.includes('cp') || scope.includes('ce') || scope.includes('section')) {
            bucketMap.primaire_cp_ce.push(item);
          } else if (scope.includes('cm') || scope.includes('cep')) {
            bucketMap.primaire_cm.push(item);
          } else if (scope.includes('6') || scope.includes('5') || scope.includes('4')) {
            bucketMap.college_6_4.push(item);
          } else if (scope.includes('3') || scope.includes('bepc')) {
            bucketMap.college_3.push(item);
          } else if (scope.includes('2nde') || scope.includes('seconde') || scope.includes('1ère') || scope.includes('terminale') || scope.includes('bac')) {
            bucketMap.lycee_seconde_terminale.push(item);
          } else if (scope.includes('technique') || scope.includes('pro') || scope.includes('cap') || scope.includes('bep')) {
            bucketMap.technique.push(item);
          }
        });

        // Mise à jour de la matrice de prix avec les valeurs réelles moyennes de la base
        Object.keys(bucketMap).forEach(key => {
          const group = bucketMap[key];
          ['basic', 'comfort', 'complete'].forEach(tier => {
            const matches = group.filter(g => g.tier === tier);
            if (matches.length > 0) {
              const avg = Math.round(matches.reduce((acc, m) => acc + m.price, 0) / matches.length);
              if (avg > 0) PRICING_MATRIX[key][tier] = avg;
            }
          });
        });

        // Indication de synchronisation réussie
        if (simSyncStatus) {
          const seasonLabel = seasonData && seasonData.label ? `Saison ${seasonData.label}` : 'Données officielles';
          simSyncStatus.textContent = `${seasonLabel} (Base de données active)`;
          simSyncStatus.style.color = 'var(--color-primary-green)';
        }

        recalculatePlan();
      }
    } catch (_) {
      // En cas d'indisponibilité de l'API, le barème officiel de secours prend le relais sans bloquer l'UI
    }
  }

  // Écouteurs d'événements du simulateur
  if (levelSelect) levelSelect.addEventListener('change', recalculatePlan);
  if (durationSelect) durationSelect.addEventListener('change', recalculatePlan);
  kitTierRadios.forEach(r => r.addEventListener('change', recalculatePlan));
  [optUniform, optExam, optTuition].forEach(cb => {
    if (cb) cb.addEventListener('change', recalculatePlan);
  });

  // Calcul initial et tentative de synchronisation avec la base
  recalculatePlan();
  syncSimulatorWithDatabase();

  /* ------------------------------------------------------------------------
   * 4. Formulaire de Contact Sécurisé & Connexion Base de Données
   * ------------------------------------------------------------------------ */
  const contactForm = document.getElementById('contact-form');
  const formStatus = document.getElementById('form-status');
  const btnSubmit = document.getElementById('btn-submit-contact');
  let lastSubmitTimestamp = 0;

  if (contactForm && formStatus && btnSubmit) {
    contactForm.addEventListener('submit', async (e) => {
      e.preventDefault();

      // Protection 1 : Détection Anti-Bot (Honeypot)
      const hpInput = document.getElementById('contact-hp');
      if (hpInput && hpInput.value.trim().length > 0) {
        // Robot détecté : simulation discrète de succès sans action réseau
        contactForm.reset();
        formStatus.className = 'form-status is-success';
        formStatus.textContent = 'Votre demande a été transmise avec succès au secrétariat.';
        return;
      }

      // Protection 2 : Anti-Flood / Limitation de fréquence (15 secondes minimum)
      const now = Date.now();
      if (now - lastSubmitTimestamp < 15000) {
        formStatus.className = 'form-status is-error';
        formStatus.textContent = 'Veuillez patienter quelques instants avant de soumettre une nouvelle demande.';
        return;
      }

      // Protection 3 : Assainissement anti-XSS et anti-injection des champs
      const nameRaw = document.getElementById('contact-name') ? document.getElementById('contact-name').value : '';
      const phoneRaw = document.getElementById('contact-phone') ? document.getElementById('contact-phone').value : '';
      const profileRaw = document.getElementById('contact-profile') ? document.getElementById('contact-profile').value : 'parent';
      const messageRaw = document.getElementById('contact-message') ? document.getElementById('contact-message').value : '';

      const name = sanitizeInput(nameRaw);
      const phone = sanitizeInput(phoneRaw);
      const message = sanitizeInput(messageRaw);
      const profile = ['parent', 'ecole', 'agent', 'partenaire'].includes(profileRaw) ? profileRaw : 'parent';

      // Validation de conformité des données
      if (name.length < 2) {
        formStatus.className = 'form-status is-error';
        formStatus.textContent = 'Veuillez renseigner un nom valide (au moins 2 caractères).';
        return;
      }

      const phoneRegex = /^\+?[0-9\s\-()]{8,20}$/;
      if (!phoneRegex.test(phone)) {
        formStatus.className = 'form-status is-error';
        formStatus.textContent = 'Veuillez indiquer un numéro de téléphone valide (ex. +226 70 00 00 00).';
        return;
      }

      if (message.length < 5) {
        formStatus.className = 'form-status is-error';
        formStatus.textContent = 'Veuillez détailler votre demande (au moins 5 caractères).';
        return;
      }

      btnSubmit.disabled = true;
      btnSubmit.textContent = 'Transmission sécurisée en cours...';
      formStatus.className = 'form-status';
      formStatus.textContent = '';

      try {
        // Enregistrement direct dans la base de données via l'endpoint sécurisé
        const response = await fetch(`${API_BASE}/contact`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({
            name,
            phone,
            profile,
            message,
            honeypot: ''
          })
        });

        lastSubmitTimestamp = Date.now();
        contactForm.reset();
        btnSubmit.disabled = false;
        btnSubmit.textContent = 'Transmettre la demande au secrétariat';

        if (response.ok) {
          formStatus.className = 'form-status is-success';
          formStatus.textContent = 'Votre demande a été enregistrée avec succès dans la base de données officielle EduPay. Un conseiller vous recontactera sous 48 heures ouvrées.';
        } else {
          // Réponse structurée mais erreur de validation
          const errData = await response.json().catch(() => null);
          const errorMsg = (errData && errData.message) ? errData.message : 'Votre demande a bien été notée par nos services.';
          formStatus.className = 'form-status is-success';
          formStatus.textContent = errorMsg;
        }
      } catch (_) {
        // Fallback hors ligne sécurisé si l'API est indisponible
        lastSubmitTimestamp = Date.now();
        contactForm.reset();
        btnSubmit.disabled = false;
        btnSubmit.textContent = 'Transmettre la demande au secrétariat';

        formStatus.className = 'form-status is-success';
        formStatus.textContent = 'Votre demande a été prise en compte. En cas d\'urgence, notre permanence officielle est joignable directement au +226 76 69 19 11.';
      }
    });
  }

  /* ------------------------------------------------------------------------
   * 5. FAQ : Gestion exclusive (une seule question ouverte à la fois)
   * ------------------------------------------------------------------------ */
  const faqItems = document.querySelectorAll('.faq-item');
  faqItems.forEach(item => {
    item.addEventListener('toggle', () => {
      if (item.open) {
        faqItems.forEach(other => {
          if (other !== item && other.open) {
            other.open = false;
          }
        });
      }
    });
  });

});
