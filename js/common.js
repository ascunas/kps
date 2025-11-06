// ===============================
// 모달 플러그인
// ===============================
(function($){
  $.fn.modalPlugin = function(options) {
    const settings = $.extend({
      openBtnClass: 'open-modal-btn',   // 모달 열기 버튼 클래스
      closeBtnClass: 'fn-modal-close', // 닫기 버튼 클래스
      showClass: 'show'                // 표시 클래스
    }, options);

    // 모달 열기 버튼 클릭 (전역)
    $(document).on('click', '.' + settings.openBtnClass, function(e){
      e.preventDefault();
      const targetId = $(this).data('target'); // id로 찾기
      if (!targetId) return;

      const $modal = $('#' + targetId);
      if ($modal.length) {
        $modal.addClass(settings.showClass);
      } else {
        console.warn(`[modalPlugin] 모달을 찾을 수 없습니다: #${targetId}`);
      }
    });

    // 닫기 버튼 클릭
    this.on('click', '.' + settings.closeBtnClass, function() {
      $(this).closest('.modal').removeClass(settings.showClass);
    });

    // 모달 바깥 클릭 시 닫기
    this.on('click', function(e) {
      if (e.target === this) {
        $(this).removeClass(settings.showClass);
      }
    });

    return this;
  };
})(jQuery);

// ===============================
// 탭 플러그인
// ===============================
(function($) {
  $.fn.tabPlugin = function() {
    return this.each(function() {
      const $container = $(this);
      const $buttons = $container.find('.tab-button');

      $buttons.on('click', function () {
        const tabId = $(this).data('tab');

        $buttons.removeClass('active');
        $(this).addClass('active');

        $('.tab-content').removeClass('active');
        $(`[data-tab-content="${tabId}"]`).addClass('active');
      });
    });
  };
})(jQuery);

// ===============================
// 툴팁 플러그인
// ===============================
(function($) {
  $.fn.tooltipPlugin = function() {
    const $tooltip = $('<div class="tooltip-box"></div>').appendTo('body');

    return this.each(function() {
      const $target = $(this);
      const text = $target.data('tooltip');

      $target.on('mouseenter', function(e) {
        $tooltip.text(text).fadeIn(200);
        positionTooltip(e);
      });

      $target.on('mousemove', function(e) {
        positionTooltip(e);
      });

      $target.on('mouseleave', function() {
        $tooltip.fadeOut(100);
      });

      function positionTooltip(e) {
        const mouseX = e.pageX + 10;
        const mouseY = e.pageY + 10;
        $tooltip.css({ top: mouseY, left: mouseX });
      }
    });
  };
})(jQuery);

// ===============================
// 아코디언 플러그인
// ===============================
(function($) {
  $.fn.accordionPlugin = function(options) {
    const settings = $.extend({
      oneOpen: true // 하나만 열릴지 여부
    }, options);

    return this.each(function() {
      const $accordion = $(this);

      $accordion.find('.accordion-header').on('click', function() {
        const $header = $(this);
        const $content = $header.next('.accordion-content');

        if (settings.oneOpen) {
          $accordion.find('.accordion-header').not($header).removeClass('active');
          $accordion.find('.accordion-content').not($content).slideUp();
        }

        $header.toggleClass('active');
        $content.slideToggle();
      });
    });
  };
})(jQuery);

// ===============================
// 드롭다운 플러그인
// ===============================
(function($) {
  $.fn.dropdownPlugin = function() {
    return this.each(function() {
      const $dropdown = $(this);
      const $toggle = $dropdown.find('.dropdown-toggle');
      const $menu = $dropdown.find('.dropdown-menu');

      $toggle.on('click', function(e) {
        e.stopPropagation();
        $('.dropdown-menu').not($menu).slideUp();
        $menu.slideToggle(150);
      });

      $menu.find('li').on('click', function() {
        const selected = $(this).text();
        console.log('선택됨:', selected);
        $menu.slideUp();
      });

      $(document).on('click', function() {
        $menu.slideUp();
      });
    });
  };
})(jQuery);

// ===============================
// 첨부파일 플러그인
// ===============================
(function($) {
  $.fn.fileAttachPlugin = function(options) {
    const settings = $.extend({
      listSelector: '.attach-list',  // 파일 목록 컨테이너
      addBtnSelector: '.btn.fn-add',    // 추가 버튼
      removeBtnSelector: '.btn.fn-remove' // 삭제 버튼
    }, options);

    return this.each(function() {
      const $container = $(this);
      const $attachList = $container.find(settings.listSelector);
      const $addBtn = $container.find(settings.addBtnSelector);
      const $removeBtn = $container.find(settings.removeBtnSelector);

      // 숨겨진 input 생성
      const $fileInput = $('<input type="file" multiple style="display:none;">');
      $('body').append($fileInput);

      // 추가 버튼 클릭 시 파일 선택창 열기
      $addBtn.on('click', function() {
        $fileInput.click();
      });

      // 파일 선택 시 리스트에 추가
      $fileInput.on('change', function() {
        const files = Array.from(this.files);
        files.forEach(file => {
          const fileItem = $(`
            <span class="file-item">
              <label class="form-label">
                <input type="checkbox" class="checkbox custom-check" />
                ${file.name}
              </label>
            </span>
          `);
          $attachList.append(fileItem);
        });
        $fileInput.val("");
      });

      // 삭제 버튼 클릭 시 선택 항목 제거
      $removeBtn.on('click', function() {
        $attachList.find('.checkbox:checked').closest('.file-item').remove();
      });
    });
  };
})(jQuery);

// ===============================
// 초기화
// ===============================
$(function () {
  $('.modal').modalPlugin();
  $('#main-tabs').tabPlugin();
  $('.tooltip-target').tooltipPlugin();
  $('#myAccordion').accordionPlugin();
  $('.dropdown').dropdownPlugin();
  $('.attach-wrap').fileAttachPlugin();
});
