# RWA Financial Product Smart Contract

Solidity를 활용하여 RWA(Real World Asset) 금융상품의 생성, 투자자별 권리 배분, 발행량 관리 및 만기 상태를 관리하는 스마트 컨트랙트 프로토타입입니다.

실물자산 기반 금융상품이 블록체인 환경에서 관리된다는 상황을 가정하고, 금융상품의 주요 상태와 투자자별 배분 정보를 스마트 컨트랙트에 기록하는 방식으로 구현했습니다.

## 주요 기능

### 1. 금융상품 생성
- 상품명, 총 발행량, 만기일을 설정하여 금융상품 생성
- 하나의 컨트랙트에서 상품이 중복 생성되는 것을 방지
- 총 발행량이 0인 상품 생성 방지
- 현재 시점보다 이전인 만기일 설정 방지

### 2. 투자자별 권리 배분
- 투자자 주소별 상품 권리 수량 기록
- 0 주소에 대한 배분 방지
- 0보다 큰 수량만 배분 가능
- 전체 배분량이 상품의 총 발행량을 초과하지 않도록 제한

### 3. 접근 제어
- 컨트랙트를 배포한 주소를 `owner`로 지정
- 상품 생성, 권리 배분 및 상환 상태 변경은 `owner`만 수행 가능

### 4. 만기 상태 관리
- 상품 만기 이전에는 상환 완료 상태로 변경할 수 없도록 제한
- 상환 완료된 상품의 중복 상환 방지

### 5. 이벤트 기록
주요 상태 변경을 추적할 수 있도록 다음 이벤트를 구현했습니다.

- `ProductCreated`
- `TokensAllocated`
- `ProductRedeemed`

## Smart Contract Structure

```text
RWAFinancialProduct
│
├── Product
│   ├── name
│   ├── totalSupply
│   ├── maturityDate
│   └── redeemed
│
├── balances
│   └── 투자자 주소별 배분 수량
│
├── createProduct()
│   └── 금융상품 생성
│
├── allocateTokens()
│   └── 투자자별 권리 배분
│
└── redeemProduct()
    └── 만기 이후 상환 상태 변경
```

## 테스트

Remix VM 환경에서 컨트랙트를 배포하고 주요 정상 및 예외 상황을 직접 테스트했습니다.

| 테스트 항목 | 결과 |
| --- | --- |
| 금융상품 생성 | 성공 |
| 투자자에게 1,000 units 배분 | 성공 |
| 투자자별 배분 수량 조회 | 성공 |
| 총 배분량 조회 | 성공 |
| 총 발행량을 초과하는 배분 시도 | 차단 |
| 비관리자의 상품 변경 시도 | 차단 |
| 중복 상품 생성 시도 | 차단 |
| 만기 이전 상환 시도 | 차단 |

테스트 예시로 총 발행량이 `10,000`인 상품을 생성하고 투자자에게 `1,000` units를 배분했습니다. 이후 총 발행량을 초과하는 `11,000` units 배분을 시도하여 해당 요청이 제한되는 것을 확인했습니다.

## 기술 스택

- Solidity ^0.8.20
- Remix IDE
- Remix VM

## 보안 및 검증 로직

스마트 컨트랙트의 상태가 임의로 변경되는 것을 줄이기 위해 다음 조건을 적용했습니다.

```solidity
require(msg.sender == owner, "Only owner can call this function");
```

관리자 권한이 없는 주소의 주요 기능 호출을 제한합니다.

```solidity
require(
    allocatedSupply + _amount <= product.totalSupply,
    "Exceeds total supply"
);
```

상품의 총 발행량보다 많은 권리가 배분되는 것을 방지합니다.

```solidity
require(
    block.timestamp >= product.maturityDate,
    "Product has not matured yet"
);
```

상품 만기 이전에 상환 완료 상태로 변경되는 것을 방지합니다.

## 프로젝트를 통해 학습한 내용

- Solidity 스마트 컨트랙트의 기본 구조
- `struct`와 `mapping`을 활용한 온체인 데이터 관리
- `modifier`와 `require`를 이용한 접근 제어 및 조건 검증
- `block.timestamp`를 활용한 만기 조건 처리
- `event`를 활용한 주요 상태 변경 기록
- 정상 동작뿐 아니라 비정상 입력과 권한 없는 호출을 고려한 테스트

## 한계 및 개선 방향

현재 프로젝트는 RWA 금융상품의 핵심 관리 과정을 단순화하여 구현한 프로토타입입니다.

`balances`를 이용해 투자자별 권리 배분량을 기록하며 실제 ERC-20 토큰을 발행하거나 실제 자금의 결제·상환을 수행하지 않습니다.

향후에는 OpenZeppelin 기반의 표준화된 권한 관리, 토큰 표준 적용, 투자자 화이트리스트/KYC 연계, 테스트 자동화 등을 추가하여 실제 금융 서비스에 가까운 구조로 확장할 수 있습니다.

## Project Structure

```text
rwa-financial-product/
├── contracts/
│   └── RWAFinancialProduct.sol
└── README.md
```