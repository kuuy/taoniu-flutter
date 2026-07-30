import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:taoniu/models/binance/spot/kline.dart';

class TradingViewChart extends StatefulWidget {
  final String symbol;
  final String interval;
  final String theme;
  final String datafeedUrl;
  final Map<String, double>? indicators;
  final List<Map<String, dynamic>>? signals;
  final List<Kline>? klines;
  final bool useTradingViewWidget;
  final Function(String symbol)? onSymbolChanged;
  final Function(int? oldestTimeSec)? onLoadMoreKlines;

  const TradingViewChart({
    super.key,
    this.symbol = 'BTCUSDT',
    this.interval = '15m',
    this.theme = 'dark',
    this.datafeedUrl = '',
    this.indicators,
    this.signals,
    this.klines,
    this.useTradingViewWidget = false,
    this.onSymbolChanged,
    this.onLoadMoreKlines,
  });

  @override
  State<TradingViewChart> createState() => _TradingViewChartState();
}

class _TradingViewChartState extends State<TradingViewChart> {
  WebViewController? _controller;
  bool _isLoading = true;
  bool _isSupported = false;

  final Map<String, _ChartViewViewState> _viewStateCache = {};
  int _lastTapMs = 0;
  bool _isFetchingMoreKlines = false;
  Offset? _hoverOffset;

  String get _currentKey =>
      '${widget.symbol.replaceAll('BINANCE:', '').toUpperCase()}:${widget.interval}';

  _ChartViewViewState get _currentViewState =>
      _viewStateCache.putIfAbsent(_currentKey, () => _ChartViewViewState());

  @override
  void initState() {
    super.initState();
    _checkSupportAndInit();
  }

  void _checkSupportAndInit() {
    if (WebViewPlatform.instance != null) {
      _isSupported = true;
      _initWebViewController();
    } else {
      _isSupported = false;
      _isLoading = false;
    }
  }

  @override
  void didUpdateWidget(covariant TradingViewChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldKlinesEmpty = oldWidget.klines == null || oldWidget.klines!.isEmpty;
    final newKlinesNotEmpty = widget.klines != null && widget.klines!.isNotEmpty;

    final klinesChanged = oldWidget.klines?.length != widget.klines?.length ||
                          !_listEquals(oldWidget.klines, widget.klines);
    final symbolChanged = oldWidget.symbol != widget.symbol;
    final intervalChanged = oldWidget.interval != widget.interval;
    final useWidgetChanged = oldWidget.useTradingViewWidget != widget.useTradingViewWidget;
    final indicatorsChanged = !_mapEquals(oldWidget.indicators, widget.indicators);
    final signalsChanged = !_signalsEquals(oldWidget.signals, widget.signals);

    if (!symbolChanged && !intervalChanged && oldWidget.klines != null && widget.klines != null) {
      final oldList = oldWidget.klines!;
      final newList = widget.klines!;
      if (oldList.isNotEmpty && newList.isNotEmpty) {
        if (newList.first.openTime < oldList.first.openTime) {
          final oldFirstTime = oldList.first.openTime;
          int prependedCount = 0;
          for (final k in newList) {
            if (k.openTime < oldFirstTime) {
              prependedCount++;
            } else {
              break;
            }
          }
          if (prependedCount > 0) {
            final viewState = _currentViewState;
            final candleW = 12.0 * viewState.zoomScale;
            viewState.scrollOffset += prependedCount * candleW;
          }
        }
      }
    }
    _isFetchingMoreKlines = false;

    if (_isSupported && _controller != null) {
      if (symbolChanged || intervalChanged || useWidgetChanged || (oldKlinesEmpty && newKlinesNotEmpty)) {
        _loadChartHtml();
      } else if (klinesChanged || indicatorsChanged || signalsChanged) {
        if (_isLoading) {
          _loadChartHtml();
        } else {
          _updateChartData();
        }
      }
    }

    if (symbolChanged || intervalChanged || klinesChanged || indicatorsChanged || signalsChanged) {
      setState(() {});
    }
  }

  bool _listEquals(List<Kline>? a, List<Kline>? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      final itemA = a[i];
      final itemB = b[i];
      if (itemA.openTime != itemB.openTime ||
          itemA.open != itemB.open ||
          itemA.high != itemB.high ||
          itemA.low != itemB.low ||
          itemA.close != itemB.close ||
          itemA.volume != itemB.volume) {
        return false;
      }
    }
    return true;
  }

  bool _mapEquals(Map<String, double>? a, Map<String, double>? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null || a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }

  bool _signalsEquals(List<Map<String, dynamic>>? a, List<Map<String, dynamic>>? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      final mapA = a[i];
      final mapB = b[i];
      if (mapA['price'] != mapB['price'] ||
          mapA['signal'] != mapB['signal'] ||
          mapA['timestamp'] != mapB['timestamp']) {
        return false;
      }
    }
    return true;
  }

  void _initWebViewController() {
    try {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0xFF131722))
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (String url) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
                _updateChartData();
              }
            },
          ),
        )
        ..addJavaScriptChannel(
          'SymbolChangedChannel',
          onMessageReceived: (JavaScriptMessage message) {
            if (widget.onSymbolChanged != null) {
              widget.onSymbolChanged!(message.message);
            }
          },
        )
        ..addJavaScriptChannel(
          'LoadMoreChannel',
          onMessageReceived: (JavaScriptMessage message) {
            if (widget.onLoadMoreKlines != null) {
              try {
                final map = jsonDecode(message.message);
                final oldestTime = map['oldestTime'] as int?;
                widget.onLoadMoreKlines!(oldestTime);
              } catch (_) {}
            }
          },
        );

      _loadChartHtml();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSupported = false;
          _isLoading = false;
        });
      }
    }
  }

  String _buildKlinesJson() {
    final List<Map<String, dynamic>> klineMapList = [];
    if (widget.klines != null && widget.klines!.isNotEmpty) {
      final sorted = List<Kline>.from(widget.klines!);
      sorted.sort((a, b) => a.openTime.compareTo(b.openTime));

      final seenTimes = <int>{};
      for (final k in sorted) {
        int timeSec = k.openTime;
        if (timeSec > 10000000000) {
          timeSec = timeSec ~/ 1000;
        }
        if (!seenTimes.contains(timeSec) && timeSec > 0) {
          seenTimes.add(timeSec);
          klineMapList.add({
            'time': timeSec,
            'open': k.open,
            'high': k.high,
            'low': k.low,
            'close': k.close,
            'volume': k.volume,
          });
        }
      }
    }
    return jsonEncode(klineMapList);
  }

  void _updateChartData() {
    if (_controller == null) return;
    final klinesJson = _buildKlinesJson();
    final indicatorsJson = jsonEncode(widget.indicators ?? {});
    final signalsJson = jsonEncode(widget.signals ?? []);
    _controller!.runJavaScript(
      'if (window.updateChartData) { window.updateChartData($klinesJson, $indicatorsJson, $signalsJson); }'
    );
  }

  void _loadChartHtml() {
    if (_controller == null) return;
    final cleanSymbol = widget.symbol.replaceAll('BINANCE:', '').toUpperCase();
    final tvInterval = _convertInterval(widget.interval);
    final klinesJson = _buildKlinesJson();
    final indicatorsJson = jsonEncode(widget.indicators ?? {});
    final signalsJson = jsonEncode(widget.signals ?? []);

    final htmlContent = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
  <style>
    html, body {
      margin: 0;
      padding: 0;
      width: 100%;
      height: 100%;
      background-color: #131722;
      overflow: hidden;
      touch-action: manipulation;
    }
    #tv_chart_container {
      width: 100%;
      height: 100%;
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      touch-action: manipulation;
    }
    #tv_chart_container iframe {
      width: 100% !important;
      height: 100% !important;
      border: 0;
    }
  </style>
  <script type="text/javascript" src="https://unpkg.com/lightweight-charts@3.8.0/dist/lightweight-charts.standalone.production.js"></script>
  <script type="text/javascript">
    if (typeof LightweightCharts === 'undefined') {
      document.write('<script src="https://cdn.jsdelivr.net/npm/lightweight-charts@3.8.0/dist/lightweight-charts.standalone.production.js"><\\/script>');
    }
  </script>
  <script type="text/javascript" src="https://s3.tradingview.com/tv.js"></script>
</head>
<body>
  <div id="tv_chart_container"></div>
  <script type="text/javascript">
    let ws = null;
    let chartInstance = null;
    let candlestickSeries = null;
    let volumeSeries = null;
    let priceLines = [];
    let currentKlinesLength = 0;
    let isFetchingOlder = false;
    let cachedKlines = [];

    function sanitizeKlines(rawKlines) {
      if (!Array.isArray(rawKlines)) return [];
      const cleanList = [];
      const seenTimes = new Set();
      for (let i = 0; i < rawKlines.length; i++) {
        const item = rawKlines[i];
        if (item && typeof item.time === 'number' && !isNaN(item.time) && item.time > 0) {
          const timeSec = item.time;
          if (!seenTimes.has(timeSec)) {
            seenTimes.add(timeSec);
            const open = parseFloat(item.open);
            const high = parseFloat(item.high);
            const low = parseFloat(item.low);
            const close = parseFloat(item.close);
            const volume = parseFloat(item.volume || 0);
            if (!isNaN(open) && !isNaN(high) && !isNaN(low) && !isNaN(close)) {
              const maxVal = Math.max(high, open, close);
              const minVal = Math.min(low, open, close);
              cleanList.push({
                time: timeSec,
                open: open,
                high: maxVal,
                low: minVal,
                close: close,
                volume: isNaN(volume) ? 0 : volume,
              });
            }
          }
        }
      }
      cleanList.sort((a, b) => a.time - b.time);
      return cleanList;
    }

    function initRealtimeWS(symbol, interval) {
      if (ws) {
        try { ws.close(); } catch(e) {}
      }
      try {
        const streamSymbol = symbol.toLowerCase();
        let streamInterval = interval.toLowerCase();
        if (streamInterval === 'd') streamInterval = '1d';
        else if (streamInterval === '1') streamInterval = '1m';
        else if (streamInterval === '15') streamInterval = '15m';
        else if (streamInterval === '240') streamInterval = '4h';
        const wsUrl = `wss://stream.binance.com:9443/ws/\${streamSymbol}@kline_\${streamInterval}`;
        ws = new WebSocket(wsUrl);
        ws.onmessage = function(event) {
          try {
            const data = JSON.parse(event.data);
            if (data && data.k && candlestickSeries) {
              const k = data.k;
              const timeSec = Math.floor(k.t / 1000);
              const open = parseFloat(k.o);
              const high = parseFloat(k.h);
              const low = parseFloat(k.l);
              const close = parseFloat(k.c);
              const volume = parseFloat(k.v);

              candlestickSeries.update({
                time: timeSec,
                open: open,
                high: high,
                low: low,
                close: close,
              });

              if (volumeSeries) {
                volumeSeries.update({
                  time: timeSec,
                  value: volume,
                  color: close >= open ? 'rgba(38, 166, 154, 0.5)' : 'rgba(239, 83, 80, 0.5)',
                });
              }
            }
          } catch(err) {}
        };
      } catch(err) {
        console.error("WS error:", err);
      }
    }

    function updatePriceLinesAndMarkers(indicators, rawSignals, interval) {
      if (!candlestickSeries) return;

      for (let i = 0; i < priceLines.length; i++) {
        try { candlestickSeries.removePriceLine(priceLines[i]); } catch(e) {}
      }
      priceLines = [];

      const fields = [
        "r3", "r2", "r1", "s1", "s2", "s3",
        "poc", "vah", "val",
        "profit_target", "take_profit_price", "stop_loss_point"
      ];

      for (let i = 0; i < fields.length; i++) {
        const field = fields[i];
        const val = indicators[field];
        if (val && parseFloat(val) > 0) {
          let linecolor = "rgba(21, 119, 96, 1)";
          let linewidth = 2;
          let linestyle = 2; // 0: Solid, 1: Dotted, 2: Dashed
          if (field === "r1" || field === "r2" || field === "r3") linecolor = "rgba(206, 147, 216, 1)";
          if (field === "s1" || field === "s2" || field === "s3") linecolor = "rgba(255, 183, 77, 1)";
          if (field === "r3" || field === "s3") { linewidth = 3; linestyle = 1; }
          if (field === "poc") { linecolor = "rgba(8, 153, 129, 1)"; linewidth = 3; linestyle = 1; }
          if (field === "vah") { linecolor = "rgba(242, 54, 69, 1)"; }
          if (field === "val") { linecolor = "rgba(41, 98, 255, 1)"; }
          if (field === "take_profit_price") { linecolor = "rgba(76, 175, 80, 1)"; linewidth = 3; linestyle = 1; }
          if (field === "profit_target") { linecolor = "rgba(248, 187, 208, 1)"; linewidth = 3; linestyle = 0; }
          if (field === "stop_loss_point") { linecolor = "rgba(255, 245, 157, 1)"; linewidth = 3; linestyle = 0; }

          const pl = candlestickSeries.createPriceLine({
            price: parseFloat(val),
            color: linecolor,
            lineWidth: linewidth,
            lineStyle: linestyle,
            axisLabelVisible: true,
            title: interval + ":" + field,
          });
          priceLines.push(pl);
        }
      }

      if (Array.isArray(rawSignals) && rawSignals.length > 0) {
        const markers = [];
        for (const sig of rawSignals) {
          if (sig.price && sig.price > 0 && sig.timestamp) {
            let timeSec = sig.timestamp;
            if (timeSec > 10000000000) timeSec = Math.round(timeSec / 1000);
            const isBuy = sig.signal === 1;
            markers.push({
              time: timeSec,
              position: isBuy ? 'belowBar' : 'aboveBar',
              color: isBuy ? 'rgba(76, 175, 80, 1)' : 'rgba(248, 187, 208, 1)',
              shape: isBuy ? 'arrowUp' : 'arrowDown',
              text: isBuy ? 'BUY' : 'SELL',
            });
          }
        }
        if (markers.length > 0) {
          markers.sort((a, b) => a.time - b.time);
          candlestickSeries.setMarkers(markers);
        } else {
          candlestickSeries.setMarkers([]);
        }
      } else {
        candlestickSeries.setMarkers([]);
      }
    }

    function renderChartWithData(rawKlines, indicators, rawSignals) {
      try {
        const symbol = "$cleanSymbol";
        const interval = "$tvInterval";

        const chartContainer = document.getElementById('tv_chart_container');
        if (!chartContainer) return;
        chartContainer.innerHTML = '';

        const validKlines = sanitizeKlines(rawKlines);
        if (validKlines.length > 0) {
          cachedKlines = validKlines;
          currentKlinesLength = validKlines.length;

          chartInstance = LightweightCharts.createChart(chartContainer, {
            width: chartContainer.clientWidth || window.innerWidth,
            height: chartContainer.clientHeight || window.innerHeight,
            layout: {
              backgroundColor: '#131722',
              textColor: '#d1d4dc',
            },
            grid: {
              vertLines: { color: 'rgba(42, 46, 57, 0.5)' },
              horzLines: { color: 'rgba(42, 46, 57, 0.5)' },
            },
            crosshair: { mode: LightweightCharts.CrosshairMode.Normal },
            rightPriceScale: {
              borderColor: 'rgba(197, 203, 206, 0.8)',
              autoScale: true,
            },
            timeScale: {
              borderColor: 'rgba(197, 203, 206, 0.8)',
              timeVisible: true,
              secondsVisible: false,
            },
            handleScroll: { mouseWheel: true, pressedMove: true, horzTouchDrag: true, vertTouchDrag: true },
            handleScale: { axisPressedMouseMove: true, mouseWheel: true, pinch: true },
          });

          function handleResize() {
            if (chartInstance && chartContainer) {
              const width = chartContainer.clientWidth || window.innerWidth;
              const height = chartContainer.clientHeight || window.innerHeight;
              if (width > 0 && height > 0) {
                chartInstance.applyOptions({ width: width, height: height });
              }
            }
          }

          window.removeEventListener('resize', handleResize);
          window.addEventListener('resize', handleResize);

          if (window.ResizeObserver) {
            const ro = new ResizeObserver(handleResize);
            ro.observe(chartContainer);
          }

          // Volume Series at bottom
          volumeSeries = chartInstance.addHistogramSeries({
            priceFormat: { type: 'volume' },
            priceScaleId: '',
            scaleMargins: { top: 0.8, bottom: 0 },
          });

          const volumeData = validKlines.map(k => ({
            time: k.time,
            value: k.volume || 0,
            color: k.close >= k.open ? 'rgba(38, 166, 154, 0.5)' : 'rgba(239, 83, 80, 0.5)',
          }));
          volumeSeries.setData(volumeData);

          // Candlestick Series
          candlestickSeries = chartInstance.addCandlestickSeries({
            upColor: '#26a69a',
            downColor: '#ef5350',
            borderVisible: false,
            wickUpColor: '#26a69a',
            wickDownColor: '#ef5350',
          });

          candlestickSeries.setData(validKlines);

          updatePriceLinesAndMarkers(indicators, rawSignals, interval);

          chartInstance.timeScale().fitContent();

          setTimeout(function() {
            if (chartInstance) {
              handleResize();
              chartInstance.timeScale().fitContent();
            }
          }, 300);

          chartContainer.addEventListener('dblclick', function() {
            if (chartInstance) {
              chartInstance.timeScale().fitContent();
            }
          });

          chartContainer.addEventListener('wheel', function(e) {
            if (chartInstance) {
              e.preventDefault();
              if (e.deltaY < 0) {
                window.zoomIn();
              } else if (e.deltaY > 0) {
                window.zoomOut();
              }
            }
          }, { passive: false });

          chartInstance.timeScale().subscribeVisibleLogicalRangeChange(function(logicalRange) {
            if (logicalRange && logicalRange.from < 5 && !isFetchingOlder) {
              isFetchingOlder = true;
              if (window.LoadMoreChannel) {
                const oldestTime = (Array.isArray(cachedKlines) && cachedKlines.length > 0) ? cachedKlines[0].time : 0;
                window.LoadMoreChannel.postMessage(JSON.stringify({ oldestTime: oldestTime }));
              }
              setTimeout(function() { isFetchingOlder = false; }, 2000);
            }
          });

          initRealtimeWS(symbol, interval);
        }
      } catch (err) {
        console.error("Render chart with data error:", err);
      }
    }

    window.zoomIn = function() {
      if (chartInstance) {
        const logicalRange = chartInstance.timeScale().getVisibleLogicalRange();
        if (logicalRange) {
          const span = logicalRange.to - logicalRange.from;
          const center = (logicalRange.from + logicalRange.to) / 2;
          const newSpan = Math.max(10, span * 0.7);
          chartInstance.timeScale().setVisibleLogicalRange({
            from: center - newSpan / 2,
            to: center + newSpan / 2,
          });
        }
      }
    };

    window.zoomOut = function() {
      if (chartInstance) {
        const logicalRange = chartInstance.timeScale().getVisibleLogicalRange();
        if (logicalRange) {
          const span = logicalRange.to - logicalRange.from;
          const center = (logicalRange.from + logicalRange.to) / 2;
          const newSpan = span * 1.4;
          chartInstance.timeScale().setVisibleLogicalRange({
            from: center - newSpan / 2,
            to: center + newSpan / 2,
          });
        }
      }
    };

    window.fitChartContent = function() {
      if (chartInstance) {
        chartInstance.timeScale().fitContent();
      }
    };

    window.updateChartData = function(rawKlines, indicators, rawSignals) {
      try {
        isFetchingOlder = false;
        const validKlines = sanitizeKlines(rawKlines);
        if (validKlines.length > 0) {
          if (!candlestickSeries || !chartInstance) {
            renderChartWithData(validKlines, indicators || {}, rawSignals || []);
            return;
          }
          const oldFirstTime = (Array.isArray(cachedKlines) && cachedKlines.length > 0) ? cachedKlines[0].time : 0;
          cachedKlines = validKlines;
          candlestickSeries.setData(validKlines);
          if (volumeSeries) {
            const volumeData = validKlines.map(k => ({
              time: k.time,
              value: k.volume || 0,
              color: k.close >= k.open ? 'rgba(38, 166, 154, 0.5)' : 'rgba(239, 83, 80, 0.5)',
            }));
            volumeSeries.setData(volumeData);
          }

          if (oldFirstTime > 0 && validKlines[0].time < oldFirstTime) {
            let prependedCount = 0;
            for (let i = 0; i < validKlines.length; i++) {
              if (validKlines[i].time < oldFirstTime) {
                prependedCount++;
              } else {
                break;
              }
            }
            if (prependedCount > 0) {
              const logicalRange = chartInstance.timeScale().getVisibleLogicalRange();
              if (logicalRange) {
                chartInstance.timeScale().setVisibleLogicalRange({
                  from: logicalRange.from + prependedCount,
                  to: logicalRange.to + prependedCount,
                });
              }
            }
          }
          currentKlinesLength = validKlines.length;
        }
        updatePriceLinesAndMarkers(indicators || {}, rawSignals || [], "$tvInterval");
      } catch (err) {
        console.error("Update chart data error:", err);
      }
    };

    class SaveLoadAdapter {
      constructor() {
        this.charts = [];
        this.studyTemplates = [];
        this.drawingTemplates = [];
      }

      getAllCharts() {
        const sCharts = localStorage.getItem('charts');
        if (sCharts) {
          try {
            this.charts = JSON.parse(sCharts);
            return Promise.resolve(this.charts);
          } catch(e) {}
        }
        return Promise.resolve([]);
      }

      removeChart(id) {
        for (let i = 0; i < this.charts.length; ++i) {
          if (this.charts[i].id === id) {
            this.charts.splice(i, 1);
            this.persist();
            return Promise.resolve();
          }
        }
        return Promise.resolve();
      }

      saveChart(chartData) {
        if (!chartData.id) {
          chartData.id = Math.random().toString();
        } else {
          this.removeChart(chartData.id);
        }
        const chart = {
          id: +chartData.id,
          name: chartData.name,
          symbol: chartData.symbol,
          resolution: chartData.resolution,
          timestamp: new Date().valueOf(),
          content: chartData.content
        };
        this.charts.push(chart);
        this.persist();
        return Promise.resolve(chart.id.toString());
      }

      getChartContent(chartId) {
        for (let i = 0; i < this.charts.length; ++i) {
          if (this.charts[i].id === chartId) {
            return Promise.resolve(this.charts[i].content);
          }
        }
        return Promise.reject('Chart not found');
      }

      getAllStudyTemplates() {
        const sTemplates = localStorage.getItem('study_templates');
        if (sTemplates) {
          try {
            this.studyTemplates = JSON.parse(sTemplates);
            return Promise.resolve(this.studyTemplates);
          } catch(e) {}
        }
        return Promise.resolve(this.studyTemplates);
      }

      removeStudyTemplate(studyTemplateInfo) {
        for (let i = 0; i < this.studyTemplates.length; ++i) {
          if (this.studyTemplates[i].name === studyTemplateInfo.name) {
            this.studyTemplates.splice(i, 1);
            this.persist();
            return Promise.resolve();
          }
        }
        return Promise.reject();
      }

      saveStudyTemplate(studyTemplateData) {
        for (let i = 0; i < this.studyTemplates.length; ++i) {
          if (this.studyTemplates[i].name === studyTemplateData.name) {
            this.studyTemplates.splice(i, 1);
            break;
          }
        }
        this.studyTemplates.push(studyTemplateData);
        this.persist();
        return Promise.resolve();
      }

      getStudyTemplateContent(studyTemplateInfo) {
        for (let i = 0; i < this.studyTemplates.length; ++i) {
          if (this.studyTemplates[i].name === studyTemplateInfo.name) {
            return Promise.resolve(this.studyTemplates[i].name);
          }
        }
        return Promise.reject();
      }

      getDrawingTemplates(toolName) {
        const sDrawings = localStorage.getItem('drawing_templates');
        if (sDrawings) {
          try { this.drawingTemplates = JSON.parse(sDrawings); } catch(e) {}
        }
        return Promise.resolve(this.drawingTemplates.map(function(t) { return t.name; }));
      }

      loadDrawingTemplate(toolName, templateName) {
        for (let i = 0; i < this.drawingTemplates.length; ++i) {
          if (this.drawingTemplates[i].name === templateName) {
            return Promise.resolve(this.drawingTemplates[i].content);
          }
        }
        return Promise.reject();
      }

      removeDrawingTemplate(toolName, templateName) {
        for (let i = 0; i < this.drawingTemplates.length; ++i) {
          if (this.drawingTemplates[i].name === templateName) {
            this.drawingTemplates.splice(i, 1);
            this.persist();
            return Promise.resolve();
          }
        }
        return Promise.reject();
      }

      saveDrawingTemplate(toolName, templateName, content) {
        for (let i = 0; i < this.drawingTemplates.length; ++i) {
          if (this.drawingTemplates[i].name === templateName) {
            this.drawingTemplates.splice(i, 1);
            break;
          }
        }
        this.drawingTemplates.push({ name: templateName, content: content });
        this.persist();
        return Promise.resolve();
      }

      persist() {
        try {
          localStorage.setItem('charts', JSON.stringify(this.charts));
          localStorage.setItem('study_templates', JSON.stringify(this.studyTemplates));
          localStorage.setItem('drawing_templates', JSON.stringify(this.drawingTemplates));
        } catch(e) {}
      }
    }

    function renderChart() {
      try {
        const useWidget = ${widget.useTradingViewWidget ? 'true' : 'false'};
        const rawKlines = $klinesJson;
        const indicators = $indicatorsJson;
        const rawSignals = $signalsJson;
        if (!useWidget && Array.isArray(rawKlines) && rawKlines.length > 0) {
          renderChartWithData(rawKlines, indicators, rawSignals);
        } else {
          const symbol = "$cleanSymbol";
          const interval = "$tvInterval";
          const chartContainer = document.getElementById('tv_chart_container');
          if (!chartContainer) return;
          chartContainer.innerHTML = '';
          const saveLoadAdapter = new SaveLoadAdapter();
          saveLoadAdapter.getAllCharts();
          new TradingView.widget({
            "autosize": true,
            "symbol": "BINANCE:" + symbol,
            "interval": interval,
            "timezone": "Etc/UTC",
            "theme": "${widget.theme.toLowerCase()}",
            "style": "1",
            "locale": "en",
            "toolbar_bg": "#f1f3f6",
            "enable_publishing": false,
            "allow_symbol_change": true,
            "container_id": "tv_chart_container",
            "hide_side_toolbar": false,
            "load_last_chart": true,
            "auto_save_delay": 3,
            "disabled_features": ["use_localstorage_for_settings"],
            "enabled_features": ["study_templates"],
            "save_load_adapter": saveLoadAdapter
          });
        }
      } catch (err) {
        console.error("Render chart error:", err);
      }
    }
    renderChart();
  </script>
</body>
</html>
''';

    _controller!.loadRequest(
      Uri.dataFromString(
        htmlContent,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8'),
      ),
    );
  }

  String _convertInterval(String interval) {
    switch (interval.toUpperCase()) {
      case '1M':
        return '1';
      case '15M':
        return '15';
      case '4H':
        return '240';
      case '1D':
      case 'D':
        return 'D';
      default:
        return 'D';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.useTradingViewWidget) {
      return _buildNativeFlutterChart();
    }

    if (!_isSupported || _controller == null) {
      return _buildNativeFlutterChart();
    }

    return Stack(
      children: [
        WebViewWidget(
          controller: _controller!,
          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
            Factory<OneSequenceGestureRecognizer>(
              () => EagerGestureRecognizer(),
            ),
          },
        ),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(color: Colors.blue),
          ),
      ],
    );
  }

  Widget _buildNativeFlutterChart() {
    final cleanSymbol = widget.symbol.replaceAll('BINANCE:', '').toUpperCase();
    final klinesList = widget.klines ?? [];

    if (klinesList.isEmpty) {
      return Container(
        color: const Color(0xFF131722),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.candlestick_chart, color: Colors.blue, size: 32),
                const SizedBox(width: 8),
                Text(
                  '$cleanSymbol (${widget.interval}) Spot Klines',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E222D),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF2A2E39)),
              ),
              child: const Text(
                'Loading Spot Klines Feed...',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    final viewState = _currentViewState;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Container(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              color: const Color(0xFF131722),
              child: MouseRegion(
                onHover: (event) {
                  setState(() {
                    _hoverOffset = event.localPosition;
                  });
                },
                onExit: (_) {
                  setState(() {
                    _hoverOffset = null;
                  });
                },
                child: Listener(
                onPointerSignal: (pointerSignal) {
                  if (pointerSignal is PointerScrollEvent) {
                    setState(() {
                      if (pointerSignal.position.dx >= constraints.maxWidth - 65.0) {
                        if (pointerSignal.scrollDelta.dy < 0) {
                          viewState.priceZoomScale = (viewState.priceZoomScale * 1.15).clamp(0.2, 5.0);
                        } else if (pointerSignal.scrollDelta.dy > 0) {
                          viewState.priceZoomScale = (viewState.priceZoomScale * 0.85).clamp(0.2, 5.0);
                        }
                      } else {
                        if (pointerSignal.scrollDelta.dy < 0) {
                          viewState.zoomScale = (viewState.zoomScale * 1.15).clamp(0.3, 5.0);
                        } else if (pointerSignal.scrollDelta.dy > 0) {
                          viewState.zoomScale = (viewState.zoomScale * 0.85).clamp(0.3, 5.0);
                        }
                      }
                    });
                  }
                },
                child: GestureDetector(
                  onTapDown: (details) {
                    final now = DateTime.now().millisecondsSinceEpoch;
                    if (now - _lastTapMs < 300) {
                      setState(() {
                        viewState.priceZoomScale = 1.0;
                        viewState.priceScrollOffset = 0.0;
                        viewState.zoomScale = 1.0;
                        viewState.scrollOffset = 0.0;
                      });
                    }
                    _lastTapMs = now;
                  },
                  onScaleUpdate: (ScaleUpdateDetails details) {
                    setState(() {
                      if (details.focalPoint.dx >= constraints.maxWidth - 65.0) {
                        viewState.priceZoomScale = (viewState.priceZoomScale * (1.0 - details.focalPointDelta.dy * 0.012)).clamp(0.2, 5.0);
                      } else {
                        viewState.zoomScale = (viewState.zoomScale * details.scale).clamp(0.3, 5.0);
                        viewState.scrollOffset += details.focalPointDelta.dx;
                        viewState.priceScrollOffset += details.focalPointDelta.dy;
                      }
                    });
                    final candleW = 12.0 * viewState.zoomScale;
                    final chartW = constraints.maxWidth - 65.0;
                    final oldestCandleX = chartW - (klinesList.length - 1) * candleW - 10.0 + viewState.scrollOffset;

                    if (oldestCandleX >= -100 && !_isFetchingMoreKlines && widget.onLoadMoreKlines != null) {
                      _isFetchingMoreKlines = true;
                      widget.onLoadMoreKlines!(klinesList.first.openTime ~/ 1000);
                    }
                  },
                  child: CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: _CandlestickChartPainter(
                      klines: klinesList,
                      indicators: widget.indicators,
                      signals: widget.signals,
                      interval: widget.interval,
                      symbol: widget.symbol,
                      zoomScale: viewState.zoomScale,
                      priceZoomScale: viewState.priceZoomScale,
                      priceScrollOffset: viewState.priceScrollOffset,
                      scrollOffset: viewState.scrollOffset,
                      hoverOffset: _hoverOffset,
                    ),
                  ),
                ),
              ),
            ),
            ),
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E222D).withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF2A2E39)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          viewState.zoomScale = (viewState.zoomScale * 1.3).clamp(0.3, 5.0);
                        });
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(6.0),
                        child: Icon(Icons.add, color: Colors.white, size: 18),
                      ),
                    ),
                    const SizedBox(width: 2),
                    InkWell(
                      onTap: () {
                        setState(() {
                          viewState.zoomScale = (viewState.zoomScale * 0.7).clamp(0.3, 5.0);
                        });
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(6.0),
                        child: Icon(Icons.remove, color: Colors.white, size: 18),
                      ),
                    ),
                    const SizedBox(width: 2),
                    InkWell(
                      onTap: () {
                        setState(() {
                          viewState.priceZoomScale = 1.0;
                          viewState.priceScrollOffset = 0.0;
                          viewState.zoomScale = 1.0;
                          viewState.scrollOffset = 0.0;
                        });
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(6.0),
                        child: Icon(Icons.fit_screen, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CandlestickChartPainter extends CustomPainter {
  final List<Kline> klines;
  final Map<String, double>? indicators;
  final List<Map<String, dynamic>>? signals;
  final String interval;
  final String symbol;
  final double zoomScale;
  final double priceZoomScale;
  final double priceScrollOffset;
  final double scrollOffset;
  final Offset? hoverOffset;

  _CandlestickChartPainter({
    required this.klines,
    this.indicators,
    this.signals,
    required this.interval,
    required this.symbol,
    this.zoomScale = 1.0,
    this.priceZoomScale = 1.0,
    this.priceScrollOffset = 0.0,
    this.scrollOffset = 0.0,
    this.hoverOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (klines.isEmpty) return;

    final backgroundPaint = Paint()..color = const Color(0xFF131722);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    final rightMargin = 65.0;
    final bottomMargin = 24.0;
    final chartWidth = size.width - rightMargin;
    final chartHeight = size.height - bottomMargin;
    final volumeHeight = chartHeight * 0.22;
    final priceHeight = chartHeight * 0.75;

    // Draw Background Symbol Watermark
    final cleanSymbol = symbol.replaceAll('BINANCE:', '').toUpperCase();
    final watermarkPainter = TextPainter(
      text: TextSpan(
        text: '$cleanSymbol  $interval',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.04),
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    watermarkPainter.paint(
      canvas,
      Offset((chartWidth - watermarkPainter.width) / 2, (priceHeight - watermarkPainter.height) / 2),
    );

    final N = klines.length;
    final candleWidth = (12.0 * zoomScale).clamp(3.0, 50.0);
    final barWidth = (candleWidth * 0.75).clamp(1.5, 35.0);

    // Calculate price range for visible candles only
    double minPrice = double.infinity;
    double maxPrice = double.negativeInfinity;
    double maxVol = 0.0;
    int visibleCount = 0;

    for (int i = 0; i < N; i++) {
      final x = chartWidth - (N - 1 - i) * candleWidth - candleWidth / 2 - 10.0 + scrollOffset;
      if (x >= -candleWidth && x <= chartWidth + candleWidth) {
        final k = klines[i];
        if (k.low < minPrice && k.low > 0) minPrice = k.low;
        if (k.high > maxPrice) maxPrice = k.high;
        if (k.volume > maxVol) maxVol = k.volume;
        visibleCount++;
      }
    }

    if (visibleCount == 0 || minPrice >= maxPrice) {
      for (final k in klines) {
        if (k.low < minPrice && k.low > 0) minPrice = k.low;
        if (k.high > maxPrice) maxPrice = k.high;
        if (k.volume > maxVol) maxVol = k.volume;
      }
    }

    final rawMinPrice = minPrice;
    final rawMaxPrice = maxPrice;
    final rawRange = rawMaxPrice - rawMinPrice;

    if (indicators != null && rawRange > 0) {
      indicators!.forEach((_, val) {
        if (val > 0) {
          if (val >= rawMinPrice - rawRange * 0.3 && val <= rawMaxPrice + rawRange * 0.3) {
            if (val < minPrice) minPrice = val;
            if (val > maxPrice) maxPrice = val;
          }
        }
      });
    }

    if (minPrice >= maxPrice) {
      minPrice = maxPrice - 1.0;
    }

    final pricePadding = (maxPrice - minPrice) * 0.06;
    minPrice -= pricePadding;
    maxPrice += pricePadding;

    final basePriceRange = maxPrice - minPrice;
    final midPrice = (maxPrice + minPrice) / 2;
    final scaledPriceRange = (basePriceRange / priceZoomScale).clamp(0.000001, double.infinity);

    final pricePerPixel = scaledPriceRange / priceHeight;
    final priceOffset = priceScrollOffset * pricePerPixel;

    final currentMinPrice = midPrice - scaledPriceRange / 2 + priceOffset;
    final currentMaxPrice = midPrice + scaledPriceRange / 2 + priceOffset;

    double priceToY(double price) {
      return priceHeight - ((price - currentMinPrice) / scaledPriceRange) * priceHeight;
    }

    String formatPrice(double price) {
      if (price >= 1000) {
        return price.toStringAsFixed(2);
      } else if (price >= 1) {
        return price.toStringAsFixed(3);
      } else if (price >= 0.01) {
        return price.toStringAsFixed(4);
      } else {
        return price.toStringAsFixed(6);
      }
    }

    String formatTime(int openTime) {
      final timeMs = openTime > 10000000000 ? openTime : openTime * 1000;
      final dt = DateTime.fromMillisecondsSinceEpoch(timeMs);
      return '${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }

    // Draw Grid Lines & Price Axis Labels
    final gridPaint = Paint()
      ..color = const Color(0xFF2A2E39).withValues(alpha: 0.5)
      ..strokeWidth = 1;

    final textStyle = const TextStyle(color: Color(0xFF868993), fontSize: 10);

    for (int i = 0; i <= 4; i++) {
      final y = (priceHeight / 4) * i;
      canvas.drawLine(Offset(0, y), Offset(chartWidth, y), gridPaint);

      final priceVal = currentMaxPrice - (scaledPriceRange / 4) * i;
      final priceLabel = formatPrice(priceVal);
      final textPainter = TextPainter(
        text: TextSpan(text: priceLabel, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(chartWidth + 6, y - 6));
    }

    // Draw Bottom Time Axis Ticks & Vertical Grid Lines
    final timeStep = (65.0 / candleWidth).ceil().clamp(3, 25);
    for (int i = N - 1; i >= 0; i -= timeStep) {
      final x = chartWidth - (N - 1 - i) * candleWidth - candleWidth / 2 - 10.0 + scrollOffset;
      if (x >= 0 && x <= chartWidth) {
        canvas.drawLine(Offset(x, 0), Offset(x, chartHeight), gridPaint);
        final timeText = formatTime(klines[i].openTime);
        final timePainter = TextPainter(
          text: TextSpan(text: timeText, style: textStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        timePainter.paint(canvas, Offset(x - timePainter.width / 2, chartHeight + 4));
      }
    }

    // Draw Current Price Highlight Tag on Right Axis
    if (klines.isNotEmpty) {
      final lastK = klines.last;
      final currentPrice = lastK.close;
      final currentY = priceToY(currentPrice);
      if (currentY >= 0 && currentY <= priceHeight) {
        final isBull = lastK.close >= lastK.open;
        final badgeColor = isBull ? const Color(0xFF26A69A) : const Color(0xFFEF5350);
        final priceStr = formatPrice(currentPrice);

        final dashPaint = Paint()
          ..color = badgeColor.withValues(alpha: 0.7)
          ..strokeWidth = 1;
        double startX = 0;
        while (startX < chartWidth) {
          canvas.drawLine(Offset(startX, currentY), Offset(startX + 4, currentY), dashPaint);
          startX += 8;
        }

        final badgeTextPainter = TextPainter(
          text: TextSpan(
            text: priceStr,
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        final badgeRect = Rect.fromLTWH(
          chartWidth + 2,
          currentY - 9,
          badgeTextPainter.width + 10,
          18,
        );
        final badgeBgPaint = Paint()..color = badgeColor;
        canvas.drawRRect(RRect.fromRectAndRadius(badgeRect, const Radius.circular(3)), badgeBgPaint);
        badgeTextPainter.paint(canvas, Offset(chartWidth + 7, currentY - 6));
      }
    }

    // Interactive Crosshair & Tooltip Badges
    Kline? activeHeaderKline = klines.isNotEmpty ? klines.last : null;

    if (hoverOffset != null && hoverOffset!.dx >= 0 && hoverOffset!.dx <= chartWidth) {
      final hX = hoverOffset!.dx;
      final hY = hoverOffset!.dy;

      int hoverIdx = N - 1 - ((chartWidth - 10.0 + scrollOffset - hX) / candleWidth).round();
      hoverIdx = hoverIdx.clamp(0, N - 1);
      final hK = klines[hoverIdx];
      activeHeaderKline = hK;

      final snappedX = chartWidth - (N - 1 - hoverIdx) * candleWidth - candleWidth / 2 - 10.0 + scrollOffset;

      final crossPaint = Paint()
        ..color = const Color(0xFF787B86).withValues(alpha: 0.75)
        ..strokeWidth = 1;

      // Vertical Line
      double startY = 0;
      while (startY < chartHeight) {
        canvas.drawLine(Offset(snappedX, startY), Offset(snappedX, startY + 4), crossPaint);
        startY += 8;
      }

      // Horizontal Line
      if (hY >= 0 && hY <= priceHeight) {
        double startX = 0;
        while (startX < chartWidth) {
          canvas.drawLine(Offset(startX, hY), Offset(startX + 4, hY), crossPaint);
          startX += 8;
        }

        final hoverPrice = currentMaxPrice - (hY / priceHeight) * scaledPriceRange;
        final hoverPriceStr = formatPrice(hoverPrice);
        final priceTagPainter = TextPainter(
          text: TextSpan(text: hoverPriceStr, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
          textDirection: TextDirection.ltr,
        )..layout();
        final pRect = Rect.fromLTWH(chartWidth + 2, hY - 8, priceTagPainter.width + 10, 16);
        canvas.drawRRect(RRect.fromRectAndRadius(pRect, const Radius.circular(2)), Paint()..color = const Color(0xFF363A45));
        priceTagPainter.paint(canvas, Offset(chartWidth + 7, hY - 6));
      }

      final timeStr = formatTime(hK.openTime);
      final timeTagPainter = TextPainter(
        text: TextSpan(text: timeStr, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr,
      )..layout();
      final tRect = Rect.fromLTWH(snappedX - timeTagPainter.width / 2 - 4, chartHeight + 2, timeTagPainter.width + 8, 16);
      canvas.drawRRect(RRect.fromRectAndRadius(tRect, const Radius.circular(2)), Paint()..color = const Color(0xFF363A45));
      timeTagPainter.paint(canvas, Offset(snappedX - timeTagPainter.width / 2, chartHeight + 4));
    }

    // Live O/H/L/C Tooltip Info Bar
    if (activeHeaderKline != null) {
      final k = activeHeaderKline;
      final chg = ((k.close - k.open) / (k.open > 0 ? k.open : 1.0)) * 100;
      final chgStr = '${chg >= 0 ? '+' : ''}${chg.toStringAsFixed(2)}%';
      final isBull = k.close >= k.open;
      final chgColor = isBull ? const Color(0xFF26A69A) : const Color(0xFFEF5350);

      final tooltipText = TextSpan(
        children: [
          TextSpan(text: '$cleanSymbol ', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          TextSpan(text: '$interval  ', style: const TextStyle(color: Color(0xFF787B86), fontSize: 11)),
          const TextSpan(text: 'O ', style: TextStyle(color: Color(0xFF787B86), fontSize: 11)),
          TextSpan(text: '${formatPrice(k.open)}  ', style: TextStyle(color: chgColor, fontSize: 11, fontWeight: FontWeight.w600)),
          const TextSpan(text: 'H ', style: TextStyle(color: Color(0xFF787B86), fontSize: 11)),
          TextSpan(text: '${formatPrice(k.high)}  ', style: TextStyle(color: chgColor, fontSize: 11, fontWeight: FontWeight.w600)),
          const TextSpan(text: 'L ', style: TextStyle(color: Color(0xFF787B86), fontSize: 11)),
          TextSpan(text: '${formatPrice(k.low)}  ', style: TextStyle(color: chgColor, fontSize: 11, fontWeight: FontWeight.w600)),
          const TextSpan(text: 'C ', style: TextStyle(color: Color(0xFF787B86), fontSize: 11)),
          TextSpan(text: '${formatPrice(k.close)}  ', style: TextStyle(color: chgColor, fontSize: 11, fontWeight: FontWeight.w600)),
          TextSpan(text: chgStr, style: TextStyle(color: chgColor, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      );

      final headerPainter = TextPainter(
        text: tooltipText,
        textDirection: TextDirection.ltr,
      )..layout();
      headerPainter.paint(canvas, const Offset(10, 8));
    }

    // Draw Candlesticks & Volume Bars
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, chartWidth, size.height));

    for (int i = 0; i < N; i++) {
      final k = klines[i];
      final x = chartWidth - (N - 1 - i) * candleWidth - candleWidth / 2 - 10.0 + scrollOffset;

      if (x < -candleWidth || x > chartWidth + candleWidth) continue;

      final isBull = k.close >= k.open;
      final candleColor = isBull ? const Color(0xFF26A69A) : const Color(0xFFEF5350);

      // Draw Volume Bar
      if (maxVol > 0) {
        final volH = (k.volume / maxVol) * volumeHeight;
        final volPaint = Paint()..color = candleColor.withValues(alpha: 0.4);
        canvas.drawRect(
          Rect.fromLTWH(x - barWidth / 2, chartHeight - volH, barWidth, volH),
          volPaint,
        );
      }

      // Draw Candlestick Wick
      final highY = priceToY(k.high);
      final lowY = priceToY(k.low);
      final wickPaint = Paint()
        ..color = candleColor
        ..strokeWidth = 1.5;
      canvas.drawLine(Offset(x, highY), Offset(x, lowY), wickPaint);

      // Draw Candlestick Body
      final openY = priceToY(k.open);
      final closeY = priceToY(k.close);
      final bodyTop = openY < closeY ? openY : closeY;
      final bodyHeight = (openY - closeY).abs().clamp(1.5, double.infinity);

      final bodyPaint = Paint()
        ..color = candleColor
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromLTWH(x - barWidth / 2, bodyTop, barWidth, bodyHeight),
        bodyPaint,
      );
    }

    // Draw Strategy Signals BUY / SELL Markers
    if (signals != null && signals!.isNotEmpty) {
      for (final sig in signals!) {
        final price = double.tryParse(sig['price']?.toString() ?? '') ?? 0.0;
        final timestamp = int.tryParse(sig['timestamp']?.toString() ?? '') ?? 0;
        final signalType = int.tryParse(sig['signal']?.toString() ?? '') ?? 0;

        if (price > 0 && timestamp > 0) {
          int timeSec = timestamp > 10000000000 ? (timestamp / 1000).round() : timestamp;
          int closestIdx = -1;
          int minDiff = 999999999;
          for (int i = 0; i < N; i++) {
            int kT = klines[i].openTime > 10000000000 ? (klines[i].openTime / 1000).round() : klines[i].openTime;
            int diff = (kT - timeSec).abs();
            if (diff < minDiff) {
              minDiff = diff;
              closestIdx = i;
            }
          }

          if (closestIdx >= 0) {
            final x = chartWidth - (N - 1 - closestIdx) * candleWidth - candleWidth / 2 - 10.0 + scrollOffset;
            if (x >= 0 && x <= chartWidth) {
              final sigY = priceToY(price);
              final isBuy = signalType == 1;
              final markerColor = isBuy ? const Color(0xFF4CAF50) : const Color(0xFFF8BBD0);

              final arrowPath = Path();
              if (isBuy) {
                arrowPath.moveTo(x, sigY + 4);
                arrowPath.lineTo(x - 5, sigY + 12);
                arrowPath.lineTo(x + 5, sigY + 12);
              } else {
                arrowPath.moveTo(x, sigY - 4);
                arrowPath.lineTo(x - 5, sigY - 12);
                arrowPath.lineTo(x + 5, sigY - 12);
              }
              arrowPath.close();

              final markerPaint = Paint()..color = markerColor;
              canvas.drawPath(arrowPath, markerPaint);
            }
          }
        }
      }
    }

    canvas.restore();

    // Draw Indicator Horizontal Overlay Lines
    if (indicators != null && indicators!.isNotEmpty) {
      indicators!.forEach((field, val) {
        if (val > 0) {
          final lineY = priceToY(val);
          if (lineY >= 0 && lineY <= priceHeight) {
            Color lineColor = const Color(0xFF157760);
            double lineW = 1.5;
            bool isDashed = true;

            if (field == 'r1' || field == 'r2' || field == 'r3') lineColor = const Color(0xFFCE93D8);
            if (field == 's1' || field == 's2' || field == 's3') lineColor = const Color(0xFFFFB74D);
            if (field == 'r3' || field == 's3') { lineW = 2.5; isDashed = true; }
            if (field == 'poc') { lineColor = const Color(0xFF089981); lineW = 2.5; isDashed = true; }
            if (field == 'vah') { lineColor = const Color(0xFFF23645); }
            if (field == 'val') { lineColor = const Color(0xFF2962FF); }
            if (field == 'take_profit_price') { lineColor = const Color(0xFF4CAF50); lineW = 2.5; isDashed = true; }
            if (field == 'profit_target') { lineColor = const Color(0xFFF8BBD0); lineW = 2.5; isDashed = false; }
            if (field == 'stop_loss_point') { lineColor = const Color(0xFFFFF59D); lineW = 2.5; isDashed = false; }

            final linePaint = Paint()
              ..color = lineColor
              ..strokeWidth = lineW;

            if (isDashed) {
              double dashWidth = 6.0, dashSpace = 4.0, startX = 0;
              while (startX < chartWidth) {
                canvas.drawLine(Offset(startX, lineY), Offset(startX + dashWidth, lineY), linePaint);
                startX += dashWidth + dashSpace;
              }
            } else {
              canvas.drawLine(Offset(0, lineY), Offset(chartWidth, lineY), linePaint);
            }

            final tagText = '$interval:$field';
            final tagPainter = TextPainter(
              text: TextSpan(
                text: tagText,
                style: TextStyle(color: lineColor, fontSize: 9, fontWeight: FontWeight.bold),
              ),
              textDirection: TextDirection.ltr,
            )..layout();

            final tagRect = Rect.fromLTWH(chartWidth - tagPainter.width - 4, lineY - 14, tagPainter.width + 8, 13);
            final bgPaint = Paint()..color = const Color(0xFF1E222D).withValues(alpha: 0.85);
            canvas.drawRRect(RRect.fromRectAndRadius(tagRect, const Radius.circular(2)), bgPaint);
            tagPainter.paint(canvas, Offset(chartWidth - tagPainter.width - 2, lineY - 14));
          }
        }
      });
    }
  }

  @override
  bool shouldRepaint(covariant _CandlestickChartPainter oldDelegate) => true;
}

class _ChartViewViewState {
  double zoomScale = 1.0;
  double scrollOffset = 0.0;
  double priceZoomScale = 1.0;
  double priceScrollOffset = 0.0;

  _ChartViewViewState();
}
