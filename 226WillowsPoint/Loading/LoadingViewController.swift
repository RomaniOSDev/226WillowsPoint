//
//  LoadingViewController.swift
//  1TrulbargrovarStrinel
//
//  Показывает загрузку в стиле приложения (градиент + анимированный индикатор), запрашивает конфиг,
//  затем переходит на ContentView или WebviewVC. Адаптируется под портрет и ландшафт.
//  Максимальное время загрузки — 15 секунд.
//

import UIKit
import SwiftUI

/// Максимальное ожидание данных конверсии перед конфиг-запросом.
private let conversionDataWaitInterval: TimeInterval = 10
/// Максимальное время загрузки (сек): при нормальном интернете не должно превышать 15.
private let maxLoadingTimeInterval: TimeInterval = 15

/// Задержка перед стартом обычного config-flow (когда нет pending push URL).
private let ordinaryStartDelayInterval: TimeInterval = 5

final class LoadingViewController: UIViewController {

    private let loadingHosting = UIHostingController(rootView: AnyView(LoadingView()))
    private var didFinishTransition = false
    private var timeoutWorkItem: DispatchWorkItem?
    private var conversionWaitWorkItem: DispatchWorkItem?
    private var conversionObserver: NSObjectProtocol?
    private var didStartConfigRequest = false
    private var ordinaryStartWorkItem: DispatchWorkItem?
    /// Флаг: config-flow уже запущен (или запланирован) — повторно не стартуем.
    private var isConfigFlowInProgress = false
    /// Показан экран «нет сети» — Retry идёт без повторной 5-секундной задержки.
    private var isShowingNoInternet = false
    /// Дошли до ветки с интернетом (ожидание conversion / config request).
    private var hasEnteredOnlineConfigFlow = false

    override func viewDidLoad() {
        super.viewDidLoad()
        addChild(loadingHosting)
        view.addSubview(loadingHosting.view)
        loadingHosting.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingHosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingHosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingHosting.view.topAnchor.constraint(equalTo: view.topAnchor),
            loadingHosting.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        loadingHosting.didMove(toParent: self)
        subscribeToConversionDataNotifications()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startConfigFlow()
    }

    private func startConfigFlow() {
        if didFinishTransition { return }
        if let pushURL = PushNotificationURLRouter.shared.consumePendingURL() {
            ordinaryStartWorkItem?.cancel()
            ordinaryStartWorkItem = nil
            isConfigFlowInProgress = true
            didFinishTransition = true
            replaceRoot(with: WebviewVC(url: pushURL))
            return
        }

        // После экрана «нет сети» — сразу повторяем проверку, без 5-секундной задержки.
        if isShowingNoInternet {
            retryAfterNoInternet()
            return
        }

        // Обычный старт: запускаем config-flow не сразу, а после задержки.
        // Это стабилизирует поведение на TestFlight, когда приложение уходит в background/foreground.
        guard !isConfigFlowInProgress, ordinaryStartWorkItem == nil else { return }
        isConfigFlowInProgress = true
        showLoadingState()

        let workItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            self.ordinaryStartWorkItem = nil
            guard !self.didFinishTransition, self.isConfigFlowInProgress else { return }
            self.startConfigFlowWithoutPush()
        }
        ordinaryStartWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + ordinaryStartDelayInterval, execute: workItem)
    }

    private func retryAfterNoInternet() {
        guard !didFinishTransition else { return }
        isShowingNoInternet = false
        isConfigFlowInProgress = true
        hasEnteredOnlineConfigFlow = false
        didStartConfigRequest = false
        showLoadingState()
        startConfigFlowWithoutPush()
    }

    private func startConfigFlowWithoutPush() {
        if didFinishTransition { return }
        isConfigFlowInProgress = true
        showLoadingState()

        NetworkAvailability.checkConnection { [weak self] isConnected in
            guard let self = self, !self.didFinishTransition else { return }
            if !isConnected {
                self.showNoInternetState()
                return
            }
            self.startConfigFlowWithInternet()
        }
    }

    private func startConfigFlowWithInternet() {
        if didFinishTransition { return }
        hasEnteredOnlineConfigFlow = true
        let config = ConfigManager.shared
        didStartConfigRequest = false

        timeoutWorkItem = DispatchWorkItem { [weak self] in
            self?.finishByTimeout()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + maxLoadingTimeInterval, execute: timeoutWorkItem!)

        if config.isSavedURLValid, let url = config.savedURL {
            cancelScheduledWork()
            transitionToWebView(url: url)
            return
        }

        waitForConversionDataThenRequestConfig()
    }

    private func showLoadingState() {
        loadingHosting.rootView = AnyView(LoadingView())
    }

    private func showNoInternetState() {
        isShowingNoInternet = true
        isConfigFlowInProgress = false
        hasEnteredOnlineConfigFlow = false
        cancelScheduledWork()
        loadingHosting.rootView = AnyView(
            NoInternetView(
                onRetry: { [weak self] in
                    self?.retryAfterNoInternet()
                }
            )
        )
    }

    private func subscribeToConversionDataNotifications() {
        guard conversionObserver == nil else { return }
        conversionObserver = NotificationCenter.default.addObserver(
            forName: .appsFlyerConversionDataReady,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleConversionDataReady()
        }
    }

    private func handleConversionDataReady() {
        guard !didFinishTransition, !didStartConfigRequest else { return }

        if isShowingNoInternet {
            NetworkAvailability.checkConnection { [weak self] isConnected in
                guard let self, isConnected else { return }
                self.retryAfterNoInternet()
            }
            return
        }

        guard hasEnteredOnlineConfigFlow else { return }
        performConfigRequest()
    }

    private func cancelScheduledWork() {
        timeoutWorkItem?.cancel()
        timeoutWorkItem = nil
        ordinaryStartWorkItem?.cancel()
        ordinaryStartWorkItem = nil
        conversionWaitWorkItem?.cancel()
        conversionWaitWorkItem = nil
    }

    private func removeConversionObserver() {
        if let observer = conversionObserver {
            NotificationCenter.default.removeObserver(observer)
            conversionObserver = nil
        }
    }

    private func finishByTimeout() {
        guard !didFinishTransition else { return }
        if didStartConfigRequest { return }
        // Последняя попытка: отправить config-запрос вместо немедленного fallback на ContentView.
        performConfigRequest()
    }

    private func performConfigRequest() {
        guard !didFinishTransition, !didStartConfigRequest else { return }
        didStartConfigRequest = true
        cancelScheduledWork()

        ConfigManager.shared.requestConfig { [weak self] result in
            guard let self = self, !self.didFinishTransition else { return }
            self.removeConversionObserver()
            switch result {
            case .success(let response):
                if response.ok, let urlString = response.url, let url = URL(string: urlString) {
                    self.transitionToWebView(url: url)
                } else {
                    self.transitionToContentViewOrSavedWebView()
                }
            case .failure:
                self.transitionToContentViewOrSavedWebView()
            }
        }
    }

    private func waitForConversionDataThenRequestConfig() {
        subscribeToConversionDataNotifications()

        // Любые сохранённые conversion-данные (в т.ч. полученные на экране offline) — сразу в запрос.
        if AppsFlyerManager.shared.conversionDataString != nil {
            performConfigRequest()
            return
        }

        conversionWaitWorkItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            guard !self.didFinishTransition, !self.didStartConfigRequest else { return }
            self.performConfigRequest()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + conversionDataWaitInterval, execute: conversionWaitWorkItem!)
    }

    private func transitionToContentViewOrSavedWebView() {
        removeConversionObserver()
        if let url = ConfigManager.shared.savedURL {
            transitionToWebView(url: url)
        } else {
            transitionToContentView()
        }
    }

    private func transitionToWebView(url: URL) {
        NotificationPermissionManager.shared.shouldShowCustomNotificationScreen { [weak self] shouldShow in
            guard let self = self, !self.didFinishTransition else { return }
            self.didFinishTransition = true
            self.removeConversionObserver()
            if shouldShow {
                let notificationVC = NotificationPermissionViewController(url: url, window: self.view.window)
                self.replaceRoot(with: notificationVC)
            } else {
                self.replaceRoot(with: WebviewVC(url: url))
            }
        }
    }

    private func transitionToContentView() {
        didFinishTransition = true
        removeConversionObserver()
        let content = UIHostingController(rootView: ContentView())
        replaceRoot(with: content)
    }

    private func replaceRoot(with vc: UIViewController) {
        guard let window = view.window else { return }
        window.rootViewController = vc
    }
}
